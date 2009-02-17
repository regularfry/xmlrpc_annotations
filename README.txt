xmlrpc_annotations
    by Alex Young
    http://github.com/regularfry/xmlrpc_annotations

== DESCRIPTION:

A library for adding annotations to XMLRPC server classes that allows
autogeneration of C# interface files for use with the XMLRPC.NET library.

== FEATURES/PROBLEMS:

* Structs, array types and void types are supported
* C# is currently hard-coded. The next revision will factor templating
  out into a separate class to allow document generation.

== SYNOPSIS:

Mixing XMLRPC::Annotations in like this:

  require 'xmlrpc/annotations'

  class Foo
    extend XMLRPC::Annotations

    def bar(a,b,opts)
      puts opts[:name]
      return [1.0, 2.0]
    end  

    xmlrpc_method :foo,
      :expects => [:string, any_of(:string, :int), struct_with([{:name => :string}])], 
      :returns => list_of(:double)
  end

  puts Foo.to_csharp

outputs:

  using System;
  using CookComputing.XmlRpc;

  namespace Rodents
  {
    namespace Bar
    {
      [XmlRpcMissingMapping(MappingAction.Ignore)]
      public struct FooStruct
      {
        public string name;
      }
    }

    public interface IBar : IXmlRpcProxy
    {
      [XmlRpcMethod("bar.foo")]
      double[] Foo(string a, System.Object b, Bar.FooStruct c);

    }
  }


== REQUIREMENTS:

* activesupport >= 2.2.2

== INSTALL:

  gem sources -a http://gems.github.com
  gem install regularfry-xlmrpc_annotations

== LICENSE:

(The MIT License)

Copyright (c) 2008 Alex Young

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
