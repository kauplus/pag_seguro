module PagSeguro
  class PaymentSession
    attr_accessor :id, :email, :token, :response

    def initialize(email, token)
      @email = email
      @token = token
    end

    def init_session
      session = RestClient.post(session_url_without_params, {:token => @token, :email => @email})
      @id = Nokogiri::XML(session).search('//session').at('id').text
    end

    def session_url_without_params
      'https://ws.pagseguro.uol.com.br/v2/sessions'
    end

  end
end