import 'package:flutter_test/flutter_test.dart';
import 'package:loja_virtual_pro/helpers/firebase_erros.dart';

void main() {
  group('getErrorString', () {
    const Map<String, String> mensagens = {
      'weak-password': 'Sua senha é muito fraca.',
      'invalid-email': 'Seu e-mail é inválido.',
      'email-already-in-use': 'E-mail já está sendo utilizado em outra conta.',
      'invalid-credential': 'E-mail ou senha incorretos.',
      'wrong-password': 'Sua senha está incorreta.',
      'user-not-found': 'Não há usuário com este e-mail.',
      'user-disabled': 'Este usuário foi desabilitado.',
      'too-many-requests': 'Muitas solicitações. Tente novamente mais tarde.',
      'operation-not-allowed': 'Operação não permitida.',
    };

    mensagens.forEach((code, mensagem) {
      test('traduz "$code"', () {
        expect(getErrorString(code), mensagem);
      });
    });

    test('usa mensagem padrão para códigos desconhecidos', () {
      expect(getErrorString('codigo-inexistente'), 'Um erro indefinido ocorreu.');
      expect(getErrorString(''), 'Um erro indefinido ocorreu.');
    });
  });
}
