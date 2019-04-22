/*:
 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)

 ## Tratando enum future cases

 [SE-0192](https://github.com/apple/swift-evolution/blob/master/proposals/0192-non-exhaustive-enums.md) adiciona a habilidade de distinguir entre enums que são fixos e enums que podem mudar no futuro.

 Uma das features de segurança do Swift é que todos os cases do enum devem ser exaustivos – que eles devem cobrir todos os cases. Enquanto isso funciona bem em uma perspectiva segura, isso causa problemas de compatibilidade quando novos casos são adicionados no futuro: um framework pode enviar algo diferente daquilo que você esperava, ou um codigo que você esta contando com ele talvez adicione um case novo causando um erro de compilação por que seu enum ja não ;e mais exaustivo.

 Com o atributo `@unknown` nós podemos distinguir sutilmente entre dois cenários: “O case default deve rodar para todos os outros cases por que não quero tratar eles individualmente” e “ eu quero tratar todos os casos individualmente, mas se alguma coisa vier no futuro use isto ao invés de causar um erro”.

 Aqui um exemplo de enum:
*/
    enum PasswordError: Error {
        case short
        case obvious
        case simple
    }
/*:
 Nós podemos escrever um código para tratar cada case usando um `switch`:
*/
    func showOld(error: PasswordError) {
        switch error {
        case .short:
            print("Your password was too short.")
        case .obvious:
            print("Your password was too obvious.")
        default:
            print("Your password was too simple.")
        }
    }
/*:
 Ele usa dois ceses específicos para senhas pequenas e obvias, mas trata o terceiro dentro do case default. 

 Agora, se no futuro nos adicionarmos um case chamado `old`, para senhas que foram utilizadas anteriormente, nosso case `default` sera automaticamente chamado mesmo que a mensagem não faça sentido – a senha não pode ser muito simples.

 Swift não pode nos alertar sobre isso por que está tecnicamente correto, então esse erro seria facilmente perdido. Felizmente, o novo atributo `@unknown` corrige isso perfeitamente – só pode ser usado no case `default`, e é pensado pra rodar novos cases que possam vir a ter no futuro.

 Por exemplo:
*/
    func showNew(error: PasswordError) {
        switch error {
        case .short:
            print("Your password was too short.")
        case .obvious:
            print("Your password was too obvious.")
        @unknown default:
            print("Your password wasn't suitable.")
        }
    }
/*:
 O código agora terá um warning por que o `switch` não é mais exaustivo – Swift quer que nos tratemos cada case explicitamente. Felizmente isso é apenas um *warning*, o que é o que faz esse atributo ser tão útil: se um framework adicionar um case no futuro você será alertado sobre isso, mas não quebrará seu código fonte.
 
 &nbsp;

 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)
 */
