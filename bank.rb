class Bank
    attr_accessor :name, :id, :accounts, :funds, :customers
    
    @@banks = 0
    @@bank_collection = []
    
    def initialize(name, funds)
        @name = name
        @funds = funds
        @customers = []
        @accounts = []
        @@banks += 1
        @id = @@banks
        @@bank_collection << self
    end
    
    def self.all_banks
        @@bank_collection
    end
    
    def add_customer(name)
        @customers << Customer.new(name)
    end
    
    def add_account(custid, balance, type)
        @accounts << Account.new(custid, balance, type)
        update_customer(@accounts.last)
        update_bank_funds(balance)
    end
    
    def show_funds
        puts "#{self.name} has $#{self.funds} in deposits"
    end
    
    def self.show_banks
        puts "#{@@banks} banks"
    end
    
    private
    
    def update_bank_funds(amount)
        @funds += amount
    end

    def update_customer(account)
        customer = @customers.find{|customer| customer.custid == account.custid}
        customer.accounts << account
    end
    
    class Account
        @@current_checking = 1000
        @@current_savings = 5000
        @@account_collection = []
        
        attr_accessor :custid, :account_number, :balance, :type
        
        def initialize(custid, balance, type)
            @custid = custid
            @balance = balance
            @type = type
            @@account_collection << self
            
            if type == :savings
                @@current_savings += 1
                @account_number = @@current_savings
            end
            
            if type == :checking
                @@current_checking += 1
                @account_number = @@current_checking
            end
        end
        
        def request_deposit(amount)
            deposit(amount)
        end
        
        def request_withdrawl(amount)
            withdrawl(amount)
        end
        
        def self.all_accounts
            @@account_collection
        end
        
        def show_balance
            puts "Account \##{@account_number} balance is: #{@balance}"
        end
        
        def validated(account, amount)
            true if amount <= account.balance
        end
        
        def deposit(amount)
            self.transact(amount)
        end
        
        def withdrawl(amount, atm)
            if validated(atm.account, amount) then
                atm.account.balance -= amount
                atm.bank.update_bank_funds(-amount)
            else
                ATM.excess_withdrawl
            end
        end
        
        protected
        
        def transact(amount)
            self.balance += amount
        end
    end
    
    class Customer
        @@custid = 0
        @@customer_collection = []
        
        attr_accessor :name, :custid, :accounts, :pin
        
        def initialize(name)
            @@custid += 1
            @custid = @@custid
            @name = name
            @pin = generate_pin
            @accounts = []
            @@customer_collection << self
        end
        
        def self.all_customers
            @@customer_collection
        end
        
        def verify_pin(entry)
            entry == @pin
        end
        
        def generate_pin
            rand(1000..9999)
        end
        
        def show_pin
            puts "pin for #{@name} is: #{@pin}"
        end
        
    end
end

class ATM
    attr_accessor :bank, :customer, :account
    def initialize(bankid, customerid, account_number, pin)
    
        raise "bank not recognized" if !bank = Bank.all_banks.detect{ |bank| bank.id == bankid.to_i }
        raise "customer not found for #{bank.name} bank" if !customer = bank.customers.detect{ |customer| customer.custid == customerid.to_i }
        raise "incorrect pin" if !customer.verify_pin(pin)
        raise "account \##{account_number} not found for #{customer.name} at #{bank.name}" if !account = bank.accounts.detect{ |account| account.account_number == account_number.to_i }
        
        @bank = bank
        @customer = customer
        @account = account
    end
    
    def deposit_to_account(amount)
        @account.request_deposit(amount)
    end
    
    def withdraw_from_account(amount)
        @account.request_withdrawl(amount)
    end
    
            
    def self.excess_withdrawl
        puts "Sorry, your requested withdrawl amount exceeds your balance."
    end
    
    def self.get_pin
        gets.chomp.to_i
    end
    
end

firstNational = Bank.new("First National", 1000000)
credUnion = Bank.new("Credit Union", 500000)
firstNational.add_customer("Matt Leininger")
firstNational.add_customer("Heather Eicher")

credUnion.add_customer("George Leininger")
credUnion.add_customer("Tom Wade")

matt = firstNational.customers.detect{|customer| customer.name == "Matt Leininger"}
matt.show_pin
heather = firstNational.customers.detect{|customer| customer.name == "Heather Eicher"}
heather.show_pin
george = credUnion.customers.detect{|customer| customer.name == "George Leininger"}
george.show_pin
tom = credUnion.customers.detect{|customer| customer.name == "Tom Wade"}
tom.show_pin

firstNational.add_account(matt.custid, 200000, :checking)
firstNational.add_account(matt.custid, 400000, :savings)
credUnion.add_account(george.custid, 105000, :checking)
credUnion.add_account(tom.custid, 200340, :savings)

# **************************************************************************************************
puts "**********DARK STAR ATM**********"

connection = false

while connection == false

    puts "Enter bank id:"
    bankid = gets.chomp
    
    puts "Enter customer id:"
    customerid = gets.chomp
    
    puts "Enter account number:"
    account_number = gets.chomp
    
    puts "Enter pin number:"
    pin = gets.chomp.to_i
    
    begin
        current = ATM.new(bankid, customerid, account_number, pin)
    rescue => e
        puts "#{e}"
    
    else
        puts "Connected to #{current.customer.name}'s #{current.bank.name} #{current.account.type} account"
        connection = true
    end
end

puts "Greetings, #{current.customer.name.split[0]}"

continue = true

while continue
    puts "Deposit, withdraw, check balance, or exit?"
    
    action = gets.chomp.downcase
 
    case action
    when "d"
        begin
            puts "Please enter deposit amount:"
            deposit = gets.chomp.to_i
            raise "invalid deposit amount" if deposit <= 0
            current.deposit_to_account(deposit)
            puts "Deposit successful."
            puts "New balance for account \##{current.account.account_number} is: #{current.account.balance}"
        rescue => e
            puts "#{e}"
        end
    when "w"
        begin
            puts "Please enter withdrawl amount:"
            withdrawl = gets.chomp.to_i
            raise "invalid withdrawl amount" if withdrawl <= 0
            current.withdraw_from_account(withdrawl)
        rescue => e
            puts "#{e}"
        end
    when "b"
        current.account.show_balance
    when "e"
        puts "Have a splendid day."
        continue = false
    else
        puts "invalid selection"
    end
end
