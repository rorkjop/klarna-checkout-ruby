require 'rspec/expectations'

RSpec::Matchers.define :have_one do |attr_name, type|
  match do |subject|
    subject.should respond_to(attr_name)
    subject.should respond_to("#{attr_name}=")
  end

  failure_message_for_should do |klass|
    "expected #{klass.inspect} to have association #{attr_name}"
  end
end
