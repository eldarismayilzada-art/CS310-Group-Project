import 'package:flutter_test/flutter_test.dart';
import 'package:clubhub/utils/email_validator.dart';

void main()
{
  group('EmailValidator Unit Tests', ()
  {
    final validator = EmailValidator();

    test('Valid email returns true', ()
    {
      expect(validator.isValid('user@example.com'), true);
    });

    test('Empty email returns false', ()
    {
      expect(validator.isValid(''), false);
    });

    test('Email without @ returns false', ()
    {
      expect(validator.isValid('userexample.com'), false);
    });

    test('Email without dot returns false', ()
    {
      expect(validator.isValid('user@examplecom'), false);
    });

    test('Email with spaces around it still validates', ()
    {
      expect(validator.isValid('  user@example.com  '), true);
    });
  });



}