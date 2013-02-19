require 'spree_core'
require 'cielo'

module SpreeCielo
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      load_config

      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
      
      BillingIntegration::CieloBillingIntegration.register
    end
    
    def self.load_config
      cielo_config = YAML.load_file(File.join(Rails.root, "config", "cielo.yml"))[Rails.env]

      Cielo.setup do |config|
        config.environment = cielo_config['environment']
        config.numero_afiliacao = cielo_config['numero_afiliacao']
        config.chave_acesso = cielo_config['chave_acesso']
        config.return_path = cielo_config['return_path']
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end