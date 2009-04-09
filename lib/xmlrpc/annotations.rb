require 'xmlrpc/annotations/formatters/c_sharp'

module XMLRPC
  # The main entry point for the library. Use <tt>extend XMLRPC::Annotations</tt> on
  # the class you want to carry the method information, and you will have
  # +xmlrpc_method+, +struct_with+, +list_of+, +any_of+ and +to_csharp+ available at
  # the class level.
  module Annotations

    # The main annotation method. Some example usages and their mapping to c# method
    # signatures are as follows:
    #
    # <tt>xmlrpc_method( :foo, :expects => [:string], :returns => :int )</tt>:: <tt>int Foo(String a);</tt>
    # <tt>xmlrpc_method( :foo, :expects => [{:bar => :string}], :returns => :int )</tt>:: <tt>int Foo(String bar);</tt>
    # <tt>xmlrpc_method( :foo, :expects => [list_of(:double)], :returns => list_of(:int) )</tt>:: <tt>int[] Foo(Double[] a);</tt>
    # <tt>xmlrpc_method( :foo, :expects => [struct_with([:int], :named => 'bar')], :returns => :int</tt>:: <tt>int Foo(FooBarStruct a);</tt>
    # <tt>xmlrpc_method( :foo, :expects => [{:bar => :string}], :returns => any_of(struct_with([:string]),:string))</tt>:: <tt>System.Object Foo(String bar);</tt>
    #    
    # +opts+ can include:
    # <tt>:expects</tt> (required)::  an array of <tt>type</tt>s. +type+ can be:
    # * a symbol, which will be capitalised to create the C# type;
    # * a single-pair hash, where the key is the parameter name and the value is the +type+;
    # * a <tt>list_of(type)</tt>, which is mapped to an array type;
    # * a <tt>struct_with([type])</tt>, which is mapped to a struct;
    # * a void-type <tt>any_of(*type)</tt>, which is mapped to a System.Object.
    # <tt>:returns</tt> (required)::  a return +type+, as for :expects
    # <tt>:classname</tt> (optional):: The exported XMLRPC method prefix. This defaults to the camelised class name.
    # <tt>:namespace</tt> (optional):: Alias for :classname.
    #
    def xmlrpc_method(method_name, opts)
      xmlrpc_api.methods[method_name] << opts

      ensure_structs_tagged opts[:expects], method_name
      ensure_structs_tagged opts[:returns], method_name
    end

    # Declare a structure. This is used to communicate a Ruby hash, which doesn't have a natural equivalent
    # in C# that XMLRPC.NET can serialise/deserialise.
    #
    # [list]
    #   Array of <tt>type</tt>s, as in xmlrpc_method.
    # [opts]
    #   Options hash. Currently only supports a <tt>:named</tt> key, which is used in constructing the 
    #   struct name.
    def struct_with(list, opts = {})
      result = XMLRPCStruct.new(list, opts)
      xmlrpc_api.structs ||= []
      xmlrpc_api.structs << result
      result
    end

    # Declare an array of a given +type+.
    def list_of(type)
      result = XMLRPCList.new
			case type
			when Symbol
        result.type = ::ActiveSupport::Inflector.singularize(type.to_s)
      else
        result.type = type
      end
      result
    end

    # Declare a union type where any of the <tt>type</tt>s passed are allowed.
    # Currently this is mapped to System.Object, which is over-broad.
    def any_of(*types)
      XMLRPCUnion.new(*types)
    end

    # Returns the C# interface as declared by applications of the xmlrpc_method
    # method.
    def to_csharp
      ::XMLRPC::Annotations::Formatters::CSharp.new(self.to_s).format(xmlrpc_api)
    end

    private
    class XMLRPCAPIDetails
      attr_reader :methods, :structs
      def initialize
        @methods = Hash.new(){|h,k| h[k] = []} 
        @structs = []
      end
    end

    def xmlrpc_api; @xmlrpc_api ||= XMLRPCAPIDetails.new; end

    def ensure_structs_tagged(opts, m)
      case opts
      when ::XMLRPC::Annotations::XMLRPCStruct
        opts.method_name = m
        opts.each {|opt|
          ensure_structs_tagged opt, m
        }
      when XMLRPCList
        ensure_structs_tagged opts.type, m
      when Array, XMLRPCUnion
        opts.each do |opt|
          ensure_structs_tagged opt, m
        end
      when Hash
        opts.each do |k,opt|
          ensure_structs_tagged opt, m
        end
      end
    end

    class XMLRPCStruct < Array 
      attr_accessor :method_name
      attr_accessor :fields

      def initialize(fields, opts = {})
        @fields = fields 
        @opts = opts
      end

      def name
        if method_name.nil?
          raise "Attempted to construct a C# struct without the method name"
        end

        result = ::ActiveSupport::Inflector.camelize(method_name.to_s)
        if @opts.has_key? :named
          result += ::ActiveSupport::Inflector.camelize(@opts[:named].to_s)
        end
        result + 'Struct'
      end
      def each
        @fields.each{|field| yield field}
      end
    end

    class XMLRPCList 
      attr_accessor :type
    end

    class XMLRPCUnion
      attr_accessor :types
      def initialize(*types)
        @types = types
      end
      def to_s
      	"System.Object"
      end
      def each
        types.each{|t| yield t}
      end
    end

  end
end


