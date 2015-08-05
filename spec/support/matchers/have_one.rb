require 'rspec/expectations'

RSpec::Matchers.define :have_one do |attr_name, options|
  match do |subject|
    expect(subject).to respond_to(attr_name)
    expect(subject).to respond_to("#{attr_name}=")

    if options[:as]
      subject.public_send("#{attr_name}=", {})
      expect(subject.public_send(attr_name).class).to eq options[:as]
    end
  end

  failure_message do |klass|
    "expected #{klass.inspect} to have has_one-association #{attr_name}"
  end
end
