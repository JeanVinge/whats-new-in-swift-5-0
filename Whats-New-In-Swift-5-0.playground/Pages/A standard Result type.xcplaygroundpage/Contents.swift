/*:
 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)

 ## Result type

 [SE-0235](https://github.com/apple/swift-evolution/blob/master/proposals/0235-add-result.md) Adiciona um tipo `Result` na biblioteca padrão, dando uma maneira mais simples e clara de lidar com erros em códigos complexos, como APIs assíncronas.

 O tipo `Result` é implementado com um enum de dois casos: `success` e `failure`. Ambos são implementados usando *generics* para que eles possam ter um valor associado à sua escolha, mas em caso de `falha` deverá se adequar com o protocolo do tipo `Error` do Swift.

 Para demonstrar `Result`, poderíamos escrever uma função que se conecta a um servidor para descobrir quantas mensagens não lidas estão sendo esperadas pelo usuário. Neste código de exemplo, teremos apenas um possível erro, ou seja, a URL solicitada não é um URL válido:
*/
enum NetworkError: Error {
    case badURL
}
/*:
 A função de busca aceita uma string de URL como seu primeiro parâmetro e um bloco de execução assincrono, como seu segundo parâmetro. Esse bloco de execução irá aceitar um `Result`, onde o caso de sucesso armazenará um inteiro, e o caso de falha será algum tipo de `NetworkError`. Na verdade, não vamos nos conectar a um servidor aqui, mas usar um bloco de execução, pelo menos, nos permite simular um código assíncrono.

 Segue o código:
*/
import Foundation

func fetchUnreadCount1(from urlString: String, completionHandler: @escaping (Result<Int, NetworkError>) -> Void)  {
    guard let url = URL(string: urlString) else {
        completionHandler(.failure(.badURL))
        return
    }
    print("Buscando \(url.absoluteString)...")
    completionHandler(.success(5))
}
/*:
Para usar esse código, precisamos verificar o valor dentro de nosso `Result` para ver se nossa chamada foi bem-sucedida ou não, assim:
*/
fetchUnreadCount1(from: "https://www.hackingwithswift.com") { result in
    switch result {
    case .success(let count):
        print("\(count) unread messages.")
    case .failure(let error):
        print(error.localizedDescription)
    }
}
/*:
 Existem mais três coisas que você deve saber antes de começar a usar o `Result` no seu próprio código.

     Primeiro, o `Result` tem um método `get()` que retorna o valor de sucesso, se existir, ou lança seu erro de outra forma. Isso permite que você converta `Result` em uma chamada comum, assim:
*/
fetchUnreadCount1(from: "https://www.hackingwithswift.com") { result in
    if let count = try? result.get() {
        print("\(count) unread messages.")
    }
}
/*:
Segundo, `Result` tem um inicializador que aceita um encerramento de lançamento: se o encerramento retornar um valor que seja usado com sucesso para o caso de `success`, caso contrário, o erro lançado é colocado no caso de `failure`.

 Por exemplo:
*/
let result = Result { try String(contentsOfFile: someFile) }
/*:
 Em terceiro lugar, em vez de usar um erro específico que você criou, você também pode usar o protocolo geral `Error`. De fato, a proposta do Swift Evolution diz que "é esperado que a maioria dos usos do Result use o `Swift.Error` como o argumento do tipo `Error`".

 Então, ao invés de usar `Result <Int, NetworkError>` você poderia usar `Result <Int, Error>`. Embora isso signifique perder a segurança dos *throws* tipados, você ganha a capacidade de lançar uma variedade de enums de erros diferentes - o que você preferir realmente depende do seu estilo de codificação.
 
  ## Transformando Result

 `Result` tem quatro outros métodos que podem ser úteis: `map()`, `flatMap()`, `mapError()` e `flatMapError()`. Cada uma deles dá a você a capacidade de transformar o sucesso ou o erro de alguma forma, e os dois primeiros funcionam de forma semelhante aos métodos do mesmo nome em `Optional`.

   O método `map()` procura dentro do `Result` e transforma o valor de sucesso em um tipo diferente de valor usando uma *closure* que você especificar. No entanto, se ele encontrar falha, ele usa isso diretamente e ignora sua transformação.

   Para demonstrar isso, vamos escrever um código que gera números aleatórios entre 0 e um número máximo e, em seguida, calcula os fatores desse número. Se o usuário solicitar um número aleatório abaixo de zero, ou se o número for primo, ou seja, ele não tiver fatores, exceto ele próprio e 1, consideraremos esses fatores como falhas.

   Podemos começar escrevendo código para modelar os dois possíveis casos de falha: o usuário tentou gerar um número aleatório abaixo de 0 e o número gerado foi primo:
*/
enum FactorError: Error {
    case belowMinimum
    case isPrime
}
/*:
Em seguida, escrevemos uma função que aceita um número máximo e retorna um número aleatório ou um erro:
*/
func generateRandomNumber(maximum: Int) -> Result<Int, FactorError> {
    if maximum < 0 {
        return .failure(.belowMinimum)
    } else {
        let number = Int.random(in: 0...maximum)
        return .success(number)
    }
}
/*
Quando isso é chamado, o resultado que retornamos será um inteiro ou um erro, então poderíamos usar o `map()` para transformá-lo:
*/
 let result1 = generateRandomNumber(maximum: 11)
 let stringNumber = result1.map { "The random number is: \($0)." }
/*:
 À medida que passamos em um número máximo válido, `Result` será um sucesso com um número aleatório. Então, usando `map()` pegaremos esse número aleatório, e usaremos *string interpolation* então retornaremos outro tipo de `Result`, desta vez do tipo `Result <String, FactorError>`.

   No entanto, se tivéssemos usado `generateRandomNumber (maximum: -11)` então `Result` seria configurado para o caso de falha com `FactorError.belowMinimum`. Então, usando `map()` ainda retornaria um `Result <String, FactorError>`, mas ele teria o mesmo caso de falha e o mesmo erro `FactorError.belowMinimum`.

   Agora que você viu como o `map()` nos permite transformar o tipo de sucesso em outro tipo, vamos continuar: temos um número aleatório, então o próximo passo é calcular os fatores para ele. Para fazer isso, escreveremos outra função que aceita um número e calcula seus fatores. Se achar que o número é primo, ele retornará uma falha `Result` com o erro `isPrime`, caso contrário ele retornará o número de fatores.

   Aqui está em código:
*/
func calculateFactors(for number: Int) -> Result<Int, FactorError> {
    let factors = (1...number).filter { number % $0 == 0 }

    if factors.count == 2 {
        return .failure(.isPrime)
    } else {
        return .success(factors.count)
    }
}
/*:
 Se quiséssemos usar `map()` para transformar a saída de `generateRandomNumber()` usando `calculateFactors()`, seria assim:
*/
let result2 = generateRandomNumber(maximum: 10)
let mapResult = result2.map { calculateFactors(for: $0) }
/*:
 No entanto, isso faz do `mapResult` um tipo bastante feio: `Result <Result <Int, FactorError>, FactorError>`. É um `Result` dentro de outro `Result`.

     Assim como com os opcionais, é aqui que o método `flatMap()` entra. Se *closure* transformada retorna um `Result`, `flatMap()` retornará o novo` Result` diretamente, em vez de trazer dentro de outro `Result`:
*/
let flatMapResult = result2.flatMap { calculateFactors(for: $0) }

