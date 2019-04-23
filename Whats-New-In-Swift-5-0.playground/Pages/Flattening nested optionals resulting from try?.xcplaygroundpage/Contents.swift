/*:
 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)

 ## Flattening optionals aninhados resultantes de try?

 [SE-0230](https://github.com/apple/swift-evolution/blob/master/proposals/0230-flatten-optional-try.md) modifica o modo que o `try?` funciona, então nested optionals são flattened para se tornarem optionals regulares. Isso faz ele trabalhar da mesma forma que optional chaining e conditional typecasts, ambos produzem flatten optionals em versões anteriores do Swift.

 Aqui um exemplo prático que demonstra a mudança:
*/
struct User {
    var id: Int

    init?(id: Int) {
        if id < 1 {
            return nil
        }

        self.id = id
    }

    func getMessages() throws -> String {
        // codigo complicado aqui
        return "No messages"
    }
}

let user = User(id: 1)
let messages = try? user?.getMessages()
/*:
 A struct `User` tem um inicializador falhável, por causa disso nós queremos ter certeza que estamos criando um usuário com um ID válido. O método `getMessages()` iria conter algum tipo de código complicado para pegar a lista de todas as mensagens para o usuário, então está marcado como `throws`; Eu fiz ele retornar uma string fixa pra que o código compilasse.

 A linha chave é a última: por que user é optional ele usa optional chaining, e por que `getMessages()` pode dar throw ele usa `try?` para converter o método throwing para um optional, então nos acabamos tendo um optional aninhado. No Swift 4.2 e anteriores, isso faria que `messages` fosse `String??` – Um optional optional string – mas no Swift 5.0 e posteriores `try?` não irá embrulhar valores em um optional se ele já for um optional, então `messages` será simplesmente `String?`.

 Esse novo comportamento é igual ao comportamento de optional chaining e conditional typecasting. Isto é, você teria de usar optional chaining muitas vezes em uma unica linha de código se quisesse, mas você não acabaria por ter vários nested optionals. Similar a isso, se você usasse optional chaining com `as?`, você ainda assim terminaria com um level de optionality, por que geralmente é isso que você quer.
 
 &nbsp;

 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)
 */
