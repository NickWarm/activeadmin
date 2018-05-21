module ActiveAdmin
  module Generators
    class PunditGenerator < Rails::Generators::Base
      desc "Add policies which resources registered in Active Admin"

      source_root File.expand_path("../templates", __FILE__)

      def generate_config_file
        generate_application_policy
        generate_page_policy
        generate_registered_policies
      end
    end
  end
end

private

def generate_application_policy
  unless File.exists? 'app/policies/application_policy.rb'
    template 'application_policy.rb', 'app/policies/application_policy.rb'
  end
end

def generate_page_policy
  unless File.exists? 'app/policies/active_admin/page_policy.rb'
    template 'page_policy.rb', 'app/policies/active_admin/page_policy.rb'
  end
end

def generate_registered_policies
  resource_class_names.each do |namespace|
    namespace.each do |class_name|
      @class = class_name
      file_path = class_name.underscore
      next if File.exists? "app/policies/#{file_path}_policy.rb"
      template 'policy.rb.erb', "app/policies/#{file_path}_policy.rb"
    end
  end
end

def resource_class_names
  resources.map do |namespace|
    namespace.map { |resource| resource.resource_class.to_s }
  end
end

def resources
  resource_collections.map do |namespace_resource_collection|
    namespace_resource_collection.select { |resource| resource.respond_to? :resource_class }
  end
end

def resource_collections
  namespaces.names.map do |namespace|
    namespaces.send(:[], namespace).resources
  end
end

def namespaces
  ActiveAdmin.application.namespaces
end
