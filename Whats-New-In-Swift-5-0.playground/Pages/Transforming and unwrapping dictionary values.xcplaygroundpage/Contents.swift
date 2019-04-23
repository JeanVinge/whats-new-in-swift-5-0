/*:
 [< Anterior](@previous)           [Home](Introduction)

 ## Transformando e desempacotando valores de dicionários com compactMapValues()

 [SE-0218](https://github.com/apple/swift-evolution/blob/master/proposals/0218-introduce-compact-map-values.md) adiciona um novo método `compactMapValues()` para dicionários, juntando a funcionalidade `compactMap()` dos arrays (“transforme meus valores, desempacote os resultados, então descarte tudo que for nulo”) com o método `mapValues()` dos dicionários (“deixe minhas chaves intactas mas transforme meus valores”).

 Um exemplo, aqui está um dicionário de pessoas em uma corrida, juntamente com os tempos que eles levaram pra finalizar em segundos. Uma pessoa não terminou, marcada como “DNF”:
*/
    let times = [
        "Hudson": "38",
        "Clarke": "42",
        "Robinson": "35",
        "Hartis": "DNF"
    ]
/*:
Nos podemos usar `compactMapValues()` para criar um novo dicionário com nomes e tempos como inteiros, com a pessoa DNF sendo removida:
*/
    let finishers1 = times.compactMapValues { Int($0) }
/*:
Como alternativa, você pode passar apenas o inicializador de `Int` diretamente para `compactMapValues()`, assim:
*/
    let finishers2 = times.compactMapValues(Int.init)
/*:
Você também pode usar `compactMapValues()` para desempacotar optionals e descrtar valores nulos sem precisar fazer nenhuma transformação de ordenação, assim:
*/
    let people = [
        "Paul": 38,
        "Sophie": 8,
        "Charlotte": 5,
        "William": nil
    ]
    
    let knownAges = people.compactMapValues { $0 }
/*:
 [< Anterior](@previous)           [Home](Introduction)
 */
