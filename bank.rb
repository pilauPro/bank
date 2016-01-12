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
    
    def update_bank_funds(amount)
        @funds += amount
    end

    def update_customer(account)
        customer = @customers.find{|customer| customer.custid == account.custid}
        customer.accounts << account
    end
    
    def show_funds
        puts "#{self.name} has $#{self.funds} in deposits"
    end
    def self.show_banks
        puts "#{@@banks} banks"
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
        
        def self.all_accounts
            @@account_collection
        end
        
    end
    
    class Customer
        @@custid = 0
        @@customer_collection = []
        
        attr_accessor :name, :custid, :accounts
        
        def initialize(name)
            @@custid += 1
            @custid = @@custid
            @name = name
            @accounts = []
            @@customer_collection << self
        end
        
        def self.all_customers
            @@customer_collection
        end
        
        def show_balance
            sum = 0
            @accounts.each{|account| sum += account.balance}
            puts "Hello, #{self.name}, your balance is: #{sum}"
        end
        
        def request_withdrawl(bank, account, amount, pin)
            withdrawl(bank, account, amount) if pin == 123
        end
        
        def request_deposit(bank, account, amount, pin)
            deposit(bank, account, amount) if pin == 123
        end
        
        private
        
        def deposit(bank, account, amount)
            account.balance += amount
            bank.update_bank_funds(amount)
        end
        
        def withdrawl(bank, account, amount)
            if validated(account, amount) then
                account.balance -= amount
                bank.update_bank_funds(-amount)
            else
                excess_withdrawl
            end
        end
        
        def excess_withdrawl
            puts "Sorry, your requested withdrawl amount exceeds your balance."
        end
        
        def validated(account, amount)
            true if amount <= account.balance
        end
    end
end

class ATM
    attr_accessor :bank, :customer, :account
    def initialize(bankid, customerid, account_number)
        bank = Bank.all_banks.detect{ |bank| bank.id == bankid.to_i }
        customer = Bank::Customer.all_customers.detect{ |customer| customer.custid == customerid.to_i }
        account = Bank::Account.all_accounts.detect{ |account| account.account_number == account_number.to_i }
        if !bank || !customer || !account
            raise "no account found"
        else
            @bank = bank
            @customer = customer
            @account = account
        end
    end
end

firstNational = Bank.new("First National", 1000000)
credUnion = Bank.new("Credit Union", 500000)
firstNational.add_customer("Matt Leininger")
firstNational.add_customer("Heather Eicher")

matt = firstNational.customers.detect{|customer| customer.name == "Matt Leininger"}
heather = firstNational.customers.detect{|customer| customer.name == "Heather Eicher"}
firstNational.add_account(matt.custid, 200000, :checking)
firstNational.add_account(matt.custid, 400000, :savings)
firstNational.add_account(heather.custid, 105000, :checking)
firstNational.add_account(heather.custid, 200340, :savings)

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
    
    begin
        current = ATM.new(bankid, customerid, account_number)
    rescue => e
        puts "#{e}"
    
    else
        puts "Connected to #{current.customer.name}'s #{current.bank.name} #{current.account.type} account"
        connection = true
    end
end

# matt_checking = firstNational.accounts.detect{|account| account.account_number == 1001}

# matt.accounts.each{|account| puts account.balance}
# matt.show_balance
# matt.request_withdrawl(firstNational, matt_checking, 20000, 123)
# matt.show_balance

# firstNational.show_funds

# puts matt_checking.balance

# matt.request_deposit(firstNational, matt_checking, 1000000, 123)

# firstNational.show_funds
