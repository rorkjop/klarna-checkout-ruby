require 'rspec/expectations'

RSpec::Matchers.define :have_one do |attr_name, options|
  match do |subject|
    subject.should respond_to(attr_name)
    subject.should respond_to("#{attr_name}=")

    if options[:as]
      subject.public_send("#{attr_name}=", {})
      subject.public_send(attr_name).class.should eq options[:as]
    end
  end

  failure_message_for_should do |klass|
    "expected #{klass.inspect} to have association #{attr_name}"
  end
end
