class Klarna::Checkout::Exception < StandardError
end

class Klarna::Checkout::BadRequest < Klarna::Checkout::Exception
end

class Klarna::Checkout::UnauthorizedException < Klarna::Checkout::Exception
end

class Klarna::Checkout::ForbiddenException < Klarna::Checkout::Exception
end

class Klarna::Checkout::NotFoundException < Klarna::Checkout::Exception
end

class Klarna::Checkout::MethodNotAllowedException < Klarna::Checkout::Exception
end

class Klarna::Checkout::NotAcceptableException < Klarna::Checkout::Exception
end

class Klarna::Checkout::UnsupportedMediaTypeException < Klarna::Checkout::Exception
end

class Klarna::Checkout::InternalServerErrorException < Klarna::Checkout::Exception
end
