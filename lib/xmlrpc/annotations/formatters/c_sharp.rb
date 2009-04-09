require 'erb'
require 'active_support/inflector'

module XMLRPC
  module Annotations
    module Formatters
      class CSharp
        def initialize(name)
          @name = name
        end
        
        def to_s
          @name
        end

        def basic_param_spec_for(spec)
          case spec
          when XMLRPCList 
            "#{basic_param_spec_for(spec.type)}[]"
          when ::XMLRPC::Annotations::XMLRPCStruct
            self.to_s + '.' + spec.name
          else
            spec.to_s
          end
        end

        def param_spec_for(spec, index)
          index_name = ('a'[0] + index).chr
          case spec
          when Hash # then we're being passed the name and type as key and value
            name = spec.keys[0]
            basic_param_spec_for(spec[name]) + ' ' + name.to_s 
          else
            basic_param_spec_for(spec) + ' ' + index_name
          end
        end

        def format(xmlrpc_api)
          template = <<-ERB_EOF
using System;
using CookComputing.XmlRpc;

namespace Rodents
{
  <%- if xmlrpc_api.structs && !xmlrpc_api.structs.empty? -%>
  namespace <%= self.to_s %>
  {
    <%- (xmlrpc_api.structs || []).each do |struct| -%>
    [XmlRpcMissingMapping(MappingAction.Ignore)]
    public struct <%= struct.name %>
    {
      <%- struct.fields.each_with_index do |field, i| -%>
      public <%= param_spec_for field, i %>;
      <%- end -%>
    }
    <%- end -%>
  }

  <%- end -%>
  public interface I<%= self.to_s %> : IXmlRpcProxy
  {
    <%- for method_name, opts_list in xmlrpc_api.methods || {} 
        for opts in opts_list
          param_arr = []
          opts[:expects].each_with_index do |t, i|
            param_arr << param_spec_for(t, i)
          end
          param_str = param_arr.join(', ')
      -%>
    [XmlRpcMethod("<%= ::ActiveSupport::Inflector.underscore( (opts[:classname] || opts[:namespace] || self).to_s )%>.<%= method_name.to_s %>")]
    <%= (basic_param_spec_for(opts[:returns])).to_s %> <%= ::ActiveSupport::Inflector.camelize(method_name.to_s) %>(<%= param_str %>);

    <%- end 
      end -%>
  }
}
          ERB_EOF
          erb = ERB.new template, nil, '-'
          erb.result(binding)
        end
      end
    end
  end
end
