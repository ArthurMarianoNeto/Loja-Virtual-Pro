import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/helpers/validators.dart';

void main() {
  group('emailValid', () {
    test('aceita e-mails válidos', () {
      expect(emailValid('fulano@gmail.com'), isTrue);
      expect(emailValid('fulano.silva@empresa.com.br'), isTrue);
      expect(emailValid('fulano+loja@dominio.io'), isTrue);
      expect(emailValid('fulano@[192.168.0.1]'), isTrue);
    });

    test('rejeita e-mails inválidos', () {
      expect(emailValid(''), isFalse);
      expect(emailValid('fulano'), isFalse);
      expect(emailValid('fulano.com'), isFalse);
      expect(emailValid('fulano@'), isFalse);
      expect(emailValid('@gmail.com'), isFalse);
      expect(emailValid('fulano@gmail'), isFalse);
      expect(emailValid('fulano@gmail.c'), isFalse);
      expect(emailValid('ful ano@gmail.com'), isFalse);
      expect(emailValid('fulano@@gmail.com'), isFalse);
    });
  });
}
