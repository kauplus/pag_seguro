module PagSeguro
  class CreditCard
    #include ActiveModel::Validations

    attr_accessor :token, :quantity, :value, :name, :cpf, :birth_date, :area_code, :phone_number

    def initialize(attributes = {})
      @token = attributes[:token]
      @quantity = attributes[:installment][:quantity]
      @value = attributes[:installment][:value]
      @name = attributes[:name]
      @cpf = attributes[:cpf]
      @birth_date = attributes[:birth_date]
      @area_code = attributes[:area_code]
      @phone_number = attributes[:phone_number]
    end
  end
end


