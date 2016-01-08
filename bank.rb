
class Bank
    attr_accessor :name, :funds, :customers
    
    @@banks = 0
    
    def initialize(name, funds)
        @name = name
        @funds = funds
        @customers = []
        @@banks += 1
    end
    
    def add_customer(name, balance)
        @customers << Customer.new(name, balance)
        @funds += balance
    end
    def show_funds
        puts "#{self.name} has $#{self.funds} in deposits"
    end
    def self.show_banks
        puts "#{@@banks} banks"
    end
    
    class Customer
        attr_accessor :name, :balance
        def initialize(name, balance)
            @name = name
            @balance = balance
        end
        
        
        def show_balance
            puts "Hello, #{self.name}, your balance is: #{self.balance}"
        end
        
        def validated(withdrawl)
            true if withdrawl <= @balance
        end
        
        def excess_withdrawl
            puts "Sorry, your requested withdrawl amount exceeds your balance."
        end
        
        def request_withdrawl(amount, pin)
            withdrawl(amount) if pin == 123
        end
        
        def request_deposit(amount, pin)
            deposit(amount) if pin == 123
        end
        
        private
        
        def deposit(deposit)
            Transact.deposit(self, deposit)
        end
        
        def withdrawl(withdrawl)
            if validated(withdrawl) then
                Transact.withdrawl(self, withdrawl)
            else
                excess_withdrawl
            end
        end
        

    end
    
    module Transact
        def Transact.deposit(customer, deposit)
            customer.balance += deposit
        end
        def Transact.withdrawl(customer, withdrawl)
            customer.balance -= withdrawl
        end
    end    
end

firstNational = Bank.new("First National", 1000000)
credUnion = Bank.new("Credit Union", 500000)
firstNational.add_customer("Matt Leininger", 300000)
firstNational.add_customer("Heather Eicher", 100000)

matt = firstNational.customers.find{|customer| customer.name == "Matt Leininger"}
heather = firstNational.customers.find{|customer| customer.name == "Heather Eicher"}

matt.request_deposit(12000, 123)
matt.request_withdrawl(1000, 123)
