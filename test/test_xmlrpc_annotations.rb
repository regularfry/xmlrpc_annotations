require 'rubygems'
require 'minitest/unit'
MiniTest::Unit.autorun

require 'xmlrpc/server'
# Require xmlrpc_annotations rather than xmlrpc/annotations. Either
# is good, but we need this to sort out the gem dependency on
# activesupport.
require 'xmlrpc_annotations'

class XMLRPCNetClass 
  extend XMLRPC::Annotations
  def self.reset
    @xmlrpc_api = ::XMLRPC::Annotations::XMLRPCAPIDetails.new
  end
end

class XMLRPCNetSubclass < XMLRPCNetClass
end

class TestXmlrpcAnnotations < MiniTest::Unit::TestCase
  def setup
		@a = XMLRPCNetClass
    @a.reset
    XMLRPCNetSubclass.reset
  end

  def test_xmlrpc_method
    @a.xmlrpc_method :string, :expects => [:string], :returns => :string
    intended_output = <<-EOF
using System;
using CookComputing.XmlRpc;

namespace Rodents
{
  public interface IXMLRPCNetClass : IXmlRpcProxy
  {
    [XmlRpcMethod("xmlrpc_net_class.string")]
    string String(string a);

  }
}
    EOF
    assert_equal intended_output,@a.to_csharp
  end

  def test_change_class_name
    assert_match(/public interface IXMLRPCNetSubclass/,  XMLRPCNetSubclass.to_csharp)
  end

  def test_change_proxy_name
    XMLRPCNetSubclass.xmlrpc_method :foo, :expects => [:string], :returns => :string
    assert_match %r{XmlRpcMethod\("xmlrpc_net_subclass},  XMLRPCNetSubclass.to_csharp
  end

  def test_change_return_type
    @a.xmlrpc_method :string, :expects => [:string], :returns => :int
    assert_match %r{int String\(string},@a.to_csharp
  end

  def test_change_param_type_and_name
    @a.xmlrpc_method :string, :expects => [:int], :returns => :string
    assert_match %r{String\(int a},@a.to_csharp
  end

  def test_change_method_name
    @a.xmlrpc_method :not_string, :expects => [:string], :returns => :string
    assert_match %r{xmlrpc_net_class.not_string},@a.to_csharp
    assert_match %r{NotString\(string},@a.to_csharp
  end

  def test_array_parameter
    @a.xmlrpc_method :string, :expects => [@a.list_of(:strings)], :returns => :string
    assert_match %r{string String\(string\[\] a\)},@a.to_csharp
  end

  def test_named_parameter
    @a.xmlrpc_method :string, :expects => [{:foo_bar => :string}], :returns => :string
    assert_match %r{string String\(string foo_bar\)},@a.to_csharp
  end

  def test_simple_struct
    @a.xmlrpc_method :string, :expects => [@a.struct_with([:string])], :returns => :string
    # Check that the struct itself is output
    assert_match %r{public struct StringStruct},@a.to_csharp
    # Now check that its name is referenced in the function call
    assert_match %r{string String\(XMLRPCNetClass.StringStruct a\)},@a.to_csharp
  end

  def test_simple_struct_named_param
    @a.xmlrpc_method :string, :expects => [@a.struct_with([{:struct_param => :string}])], :returns => :string
    assert_match %r{public string struct_param;},@a.to_csharp
  end

  def test_simple_struct_list_param
    @a.xmlrpc_method :string, :expects => [@a.struct_with([{:struct_param =>@a.list_of(:string)}])], :returns => :string
    assert_match %r{public string\[\] struct_param;},@a.to_csharp
  end

  def test_named_struct_param
    @a.xmlrpc_method :called_with_struct, 
      :expects => [
        {:my_struct =>@a.struct_with([{:name => :string}, {:value => :int}])}
    ], :returns => :string
    assert_match %r{public struct CalledWithStructStruct},@a.to_csharp
		assert_match %r{string CalledWithStruct\(XMLRPCNetClass\.CalledWithStructStruct my_struct\)}, @a.to_csharp
  end
  
  def test_list_return_param
    @a.xmlrpc_method :returns_list, :expects => [], :returns =>@a.list_of(:string)
    assert_match %r{string\[\] ReturnsList\(\)},@a.to_csharp
  end

  def test_change_xmlrpc_class_name
    @a.xmlrpc_method :returns_list, :expects => [], :returns =>@a.list_of(:string), :classname => :foobar
    assert_match %r{XmlRpcMethod\("foobar.returns_list},@a.to_csharp
  end
  
  def test_returned_struct
    @a.xmlrpc_method :returns_struct, :expects => [], :returns =>@a.list_of(@a.struct_with([:string]))
    assert_match %r{public struct ReturnsStruct},@a.to_csharp
  end
  
  def test_mapping_attribute
    @a.xmlrpc_method :returns_struct, :expects => [], :returns =>@a.list_of(@a.struct_with([:string]))
    assert_match(%r{\[XmlRpcMissingMapping\(MappingAction\.Ignore\)\]\s*public struct ReturnsStructStruct}m, @a.to_csharp)
  end

  def test_takes_anything
    @a.xmlrpc_method :takes_anything, :expects => [@a.any_of(:string, :int)], :returns => :string
    assert_match %r{string TakesAnything\(System\.Object a\)},@a.to_csharp
  end

	def test_takes_anything_inc_struct
    @a.xmlrpc_method :takes_anything, :expects => [@a.any_of(:string, @a.struct_with([{:href => :string}]))], :returns => :string
		assert_match %r{public struct TakesAnythingStruct}, @a.to_csharp
	end

	def test_more_than_one_struct
		@a.xmlrpc_method :takes_two_structs, :expects => [@a.struct_with([:string], :named => 'foo'), @a.struct_with([:int], :named => 'bar')],
			:returns => :string
		assert_match %r{public struct TakesTwoStructsFooStruct}, @a.to_csharp
		assert_match %r{public struct TakesTwoStructsBarStruct}, @a.to_csharp
	end

	def test_takes_list_of_anything
		@a.xmlrpc_method :takes_list_of_anything, :expects => [@a.list_of(@a.any_of(@a.struct_with([:string]), :string))],
			:returns => :string
		assert_match %r{public struct TakesListOfAnythingStruct}, @a.to_csharp
		assert_match %r{string TakesListOfAnything\(System\.Object\[\] a\)}, @a.to_csharp
	end

  def test_namespace_or_classname
    @a.xmlrpc_method :a, :expects => [], :returns => :void, :classname => :foo
    classname_string = @a.to_csharp
    @a.reset
    @a.xmlrpc_method :a, :expects => [], :returns => :void, :namespace => :foo
    assert_equal classname_string, @a.to_csharp
  end

  def test_overload
    @a.xmlrpc_method :a, :expects => [:string], :returns => :void
    @a.xmlrpc_method :a, :expects => [], :returns => :void

    assert_match %r{void A\(\)}, @a.to_csharp
    assert_match %r{void A\(string a\)}, @a.to_csharp
  end
end
