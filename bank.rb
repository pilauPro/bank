class Bank
    attr_accessor :name, :accounts, :funds, :customers
    
    @@banks = 0
    
    def initialize(name, funds)
        @name = name
        @funds = funds
        @customers = []
        @@banks += 1
        @accounts = []
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
        
        attr_accessor :custid, :account_number, :balance, :type
        
        def initialize(custid, balance, type)
            @custid = custid
            @balance = balance
            @type = type
            
            if type == :savings
                @@current_savings += 1
                @account_number = @@current_savings
            end
            
            if type == :checking
                @@current_checking += 1
                @account_number = @@current_checking
            end
        end
    end
    
    class Customer
        @@custid = 0
        attr_accessor :name, :custid, :accounts
        def initialize(name)
            @@custid += 1
            @custid = @@custid
            @name = name
            @accounts = []
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

firstNational = Bank.new("First National", 1000000)
credUnion = Bank.new("Credit Union", 500000)
firstNational.add_customer("Matt Leininger")
firstNational.add_customer("Heather Eicher")

firstNational.show_funds


matt = firstNational.customers.detect{|customer| customer.name == "Matt Leininger"}
heather = firstNational.customers.detect{|customer| customer.name == "Heather Eicher"}
firstNational.add_account(matt.custid, 200000, :checking)
firstNational.add_account(matt.custid, 400000, :savings)
firstNational.add_account(heather.custid, 105000, :checking)
firstNational.add_account(heather.custid, 200340, :savings)

matt_checking = firstNational.accounts.detect{|account| account.account_number == 1001}

matt.accounts.each{|account| puts account.balance}
matt.show_balance
matt.request_withdrawl(firstNational, matt_checking, 20000, 123)
matt.show_balance

firstNational.show_funds

puts matt_checking.balance

matt.request_deposit(firstNational, matt_checking, 1000000, 123)

firstNational.show_funds