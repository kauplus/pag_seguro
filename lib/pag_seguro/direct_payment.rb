module PagSeguro
  class DirectPayment
    include ActiveModel::Validations

    attr_accessor :id, :email, :token, :items, :sender, :shipping, :extra_amount, :redirect_url, :max_uses, :max_age, :response
    attr_accessor :method, :mode, :credit_card, :billing
    validates_presence_of :email, :token
    validates_format_of :extra_amount, with: /^\d+\.\d{2}$/, message: " must be a decimal and have 2 digits after the dot", allow_blank: true
    validates_format_of :redirect_url, with: URI::regexp(%w(http https)), message: " must give a correct url for redirection", allow_blank: true
    validate :max_uses_number, :max_age_number

    def initialize(email = nil, token = nil, options = {})
      @email        = email unless email.nil?
      @token        = token unless token.nil?
      @id           = options[:id]
      @sender       = options[:sender] || Sender.new
      @credit_card  = options[:credit_card]
      @shipping     = options[:shipping]
      @billing      = options[:billing]
      @items        = options[:items] || []
      @extra_amount = options[:extra_amount]
      @mode         = options[:mode] || 'default'
      @method       = options[:method]
    end

    def direct_payment_url
      "https://ws.pagseguro.uol.com.br/v2/transactions"
    end

    def checkout_xml
      xml_content = File.open( File.dirname(__FILE__) + "/direct_payment.xml.haml" ).read
      Haml::Engine.new(xml_content).render(nil,
        items: @items,
        payment: self,
        sender: @sender,
        shipping: @shipping,
        billing: @billing,
        credit_card: @credit_card
        )
    end

    def direct_payment_url_with_params
      "#{direct_payment_url}?email=#{@email}&token=#{@token}"
    end

    def code
      @response ||= parse_checkout_response
      parse_code
    end

    def date
      @response ||= parse_checkout_response
      parse_date
    end

    def boleto_link
      @response ||= parse_checkout_response
      parse_boleto
    end

    def reset!
      @response = nil
    end


    protected

    def send_checkout
      RestClient.post(direct_payment_url_with_params, checkout_xml, content_type: "application/xml") { |resp, request, result| resp }
    end


      def parse_checkout_response
        response = send_checkout
        if response.code == 200
          response.body
        elsif response.code == 401
          raise Errors::Unauthorized
        elsif response.code == 400
          raise Errors::InvalidData.new(response.body)
        else
          raise Errors::UnknownError.new(response)
        end
      end

      def parse_date
        DateTime.iso8601( Nokogiri::XML(@response.body).css("transaction date").first.content )
      end

      def parse_boleto
        Nokogiri::XML(@response.body).css("transaction paymentLink").first.content
      end

      def parse_code
        Nokogiri::XML(@response.body).css("transaction code").first.content
      end
  end
end