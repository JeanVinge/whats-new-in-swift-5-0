/*:
 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)

 ## Customizando string interpolation

 [SE-0228](https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md) reformulou dramaticamente o sistema de *string interpolation* do Swift, tornando-o mais eficiente e flexível, e criando uma nova gama de recursos antes impossíveis.

 Em sua forma mais básica, o novo sistema de *string interpolation* nos permite controlar como os objetos aparecem nas strings. Swift tem comportamento padrão para estruturas que é útil para *debug*, porque ele mostra o nome da estrutura seguido por todas as suas propriedades. Mas se você estava trabalhando com classes (que não têm esse comportamento), ou queria formatar essa saída para que pudesse ser voltada para o usuário, então você poderia usar o novo sistema de *string interpolation*.

 Por exemplo, se tivessemos uma struct como essa:
*/
struct User {
    var name: String
    var age: Int
}
/*:
 Se nós quiséssemos adicionar uma *string interpolation* especial para que nós mostrarmos os usuários perfeitamente, adicionaríamos uma extensão a String.StringInterpolation com um novo método `appendInterpolation()`. O Swift já possui vários destes, e usa a *interpolation* *type* - nesse caso, `User` para descobrir qual método chamar.

 Neste caso, vamos adicionar uma implementação que coloca o nome e a idade do usuário em uma única string e, em seguida, chama um dos métodos `appendInterpolation()` internos para adicionar isso à nossa string, assim:
*/
extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: User) {
        appendInterpolation("Meu nome é \(value.name) e eu tenho \(value.age) anos")
    }
}
/*:
  Agora podemos criar um usuário e mostrar seus dados:
*/
 let user = User(name: "Guybrush Threepwood", age: 33)
 print("Detalhes do usuário: \(user)")
/*:
 Isso vai imprimir **Detalhes do usuário: Meu nome é Guybrush Threepwood e tenho 33**, enquanto que com a *string interpolation* personalizada teria sido mosrrado **Detalhes do usuário: Usuário (nome: "Guybrush Threepwood", idade: 33)** É claro que essa funcionalidade não é diferente de apenas implementar o protocolo `CustomStringConvertible`, então vamos passar para usos mais avançados.

 Seu método de *interpolation* personalizado pode levar quantos parâmetros forem necessários, rotulados ou não rotulados. Por exemplo, poderíamos adicionar uma *interpolation* para mostrar números usando vários estilos, como este:
*/
import Foundation

extension String.StringInterpolation {
    mutating func appendInterpolation(_ number: Int, style: NumberFormatter.Style) {
        let formatter = NumberFormatter()
        formatter.numberStyle = style

        if let result = formatter.string(from: number as NSNumber) {
            appendLiteral(result)
        }
    }
}
/*:
 A classe `NumberFormatter` tem vários estilos, incluindo moeda ($ 72.83), ordinal (1st, 12th) e spell out (cinco, quarenta e três). Então, podemos criar um número aleatório e soletrá-lo em uma string como esta:
*/
 let number = Int.random(in: 0...100)
 let lucky = "O número da sorte é \(number, style: .spellOut)."
 print(lucky)
/*:
Você pode chamar `appendLiteral()` quantas vezes precisar, ou mesmo não, se necessário. Por exemplo, poderíamos adicionar uma *string interpolation* para repetir uma string várias vezes, assim:
*/
extension String.StringInterpolation {
    mutating func appendInterpolation(repeat str: String, _ count: Int) {
        for _ in 0 ..< count {
            appendLiteral(str)
        }
    }
}

print("Baby shark \(repeat: "doo ", 6)")
/*:
E como esses são apenas métodos regulares, você pode usar toda a gama de funcionalidades do Swift. Por exemplo, podemos adicionar uma *interpolation* que une uma matriz de strings, mas se essa matriz estiver vazia, execute uma *closure* que retorne uma string:
*/
extension String.StringInterpolation {
    mutating func appendInterpolation(_ values: [String], empty defaultValue: @autoclosure () -> String) {
        if values.count == 0 {
            appendLiteral(defaultValue())
        } else {
            appendLiteral(values.joined(separator: ", "))
        }
    }
}

let names = ["Harry", "Ron", "Hermione"]
print("List of students: \(names, empty: "No one").")
/*:
 Usar `@autoclosure` significa que podemos usar valores simples ou chamar funções complexas para o valor padrão, mas nada disso será feito a menos que `values.count` seja zero.

 Com uma combinação dos protocolos `ExpressibleByStringLiteral` e `ExpressibleByStringInterpolation` agora é possível criar tipos inteiros usando a interpolação de strings e, se adicionarmos `CustomStringConvertible`, podemos até fazer esses tipos serem impressos como strings da maneira que quisermos.

 Para fazer isso funcionar, precisamos cumprir alguns critérios específicos:

 - Qualquer tipo que criamos deve estar de acordo com o `ExpressibleByStringLiteral`, o` ExpressibleByStringInterpolation` e o `CustomStringConvertible`. Este último é necessário apenas se você quiser personalizar a forma como o tipo é mostrado.
 - *Dentro* do seu tipo precisa ser uma estrutura aninhada chamada `StringInterpolation` que esteja de acordo com o `StringInterpolationProtocol`.
 - A estrutura aninhada precisa ter um inicializador que aceite dois inteiros nos informando aproximadamente quantos dados ela pode esperar.
 - Ele também precisa implementar um método `appendLiteral()`, assim como um ou mais métodos `appendInterpolation()`.
 - Seu tipo principal precisa ter dois inicializadores que permitem que ele seja criado a partir de literais de string e interpolações de string.

 Podemos juntar tudo isso em um tipo de exemplo que pode construir HTML a partir de vários elementos comuns. O "bloco de rascunho" dentro da estrutura aninhada `StringInterpolation` será uma string: cada vez que um novo literal ou *interpolation* for adicionado, nós o anexaremos à string. Para ajudar você a ver exatamente o que está acontecendo, adicionei algumas chamadas `print()` aos vários métodos de anexação.

 Aqui está o código.
*/
struct HTMLComponent: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, CustomStringConvertible {
    struct StringInterpolation: StringInterpolationProtocol {
        // start with an empty string
        var output = ""

        // allocate enough space to hold twice the amount of literal text
        init(literalCapacity: Int, interpolationCount: Int) {
            output.reserveCapacity(literalCapacity * 2)
        }

        // a hard-coded piece of text – just add it
        mutating func appendLiteral(_ literal: String) {
            print("Adicionando \(literal)")
            output.append(literal)
        }

        // a Twitter username – add it as a link
        mutating func appendInterpolation(twitter: String) {
            print("Adicionando \(twitter)")
            output.append("<a href=\"https://twitter/\(twitter)\">@\(twitter)</a>")
        }

        // an email address – add it using mailto
        mutating func appendInterpolation(email: String) {
            print("Adicionando \(email)")
            output.append("<a href=\"mailto:\(email)\">\(email)</a>")
        }
    }

    // the finished text for this whole component
    let description: String

    // create an instance from a literal string
    init(stringLiteral value: String) {
        description = value
    }

    // create an instance from an interpolated string
    init(stringInterpolation: StringInterpolation) {
        description = stringInterpolation.output
    }
}
/*:
Agora podemos criar e usar uma instância de `HTMLComponent` usando a *string interpolation* como esta:
*/
 let text: HTMLComponent = "Você deveria me seguir no twitter \(twitter: "twostraws"), ou me mandar email em \(email: "paul@hackingwithswift.com")."
 print(text)
/*:
 Graças às chamadas `print()` que foram espalhadas por dentro, você verá exatamente como funciona a funcionalidade de *string interpolation*: você verá “Anexando Você deve me seguir no Twitter”, “Anexando twostraws”, “Adicionando você pode me enviar um e-mail em “,“ Adicionando paul@hackingwithswift.com ”e, finalmente,“ Adicionando. ”- cada parte aciona uma chamada de método e é adicionada à nossa string.

 &nbsp;

 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)
 */
