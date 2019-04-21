/*:
 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)

 ## Dynamically callable types

 [SE-0216](https://github.com/apple/swift-evolution/blob/master/proposals/0216-dynamic-callable.md) adiciona o novo atributo `@dynamicCallable` ao Swift, que traz consigo a abilidade de marcar um tipo como sendo directly callable. É um syntactic sugar invés de qualquer mágica de compilador, efetivamente `random(numberOfZeroes: 3)` em `random.dynamicallyCall(withKeywordArguments: ["numberOfZeroes": 3])`.

 `@dynamicCallable` é a extensão natural do Swift 4.2's `@dynamicMemberLookup`, e serve ao mesmo proposito: fazer com que fique mais fácil para um código em Swift trabalhar juntamente com linguagens dinamicas como Python e JavaScript.

 Para adicionar essa funcionalidade para seus próprios tipos, você precisa adicionar o atributo `@dynamicCallable` mais `func dynamicallyCall(withArguments args: [Int]) -> Double` e/ou `func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Double`.

 O primeiro deles é usado quando você chama o tipo sem o nome do parametro (e.g. `a(b, c)`), e o segundo é usando quando você provê os nomes dos parametros (e.g. `a(b: cat, c: dog)`).

 `@dynamicCallable` é realmente flexivel sobre qual tipo de dado o método aceita e retorna, permitindo voce o beneficio do Swift type safety enquanto enquanto ainda tem algum espaço de contorção para uso avançado. Então, para o primeiro método (sem nome de parametro) você consegue usar qualquer coisa que conforme com `ExpressibleByArrayLiteral` assim como arrays, pedaços de array, e sets, e para o segundo método (com nomes de parametros) você pode utilizar qualquer coisa que conforme com `ExpressibleByDictionaryLiteral` assim como dicionários e pares chave valor.

 Assim como aceita a variedade de entradas, você também pode fornecer várias sobrecargas para uma variedade de saídas – um pode retornar uma string, outro um inteiro, e assim por diante. Enaquanto o Swift conseguir saber qual usar, você pode misturar e combinar tudo que você quiser.

 Vamos ver um exemplo. Aqui uma struct que gera numeros entre 0 e um máximo, dependendo de qual entrada é passada:
*/
import Foundation

@dynamicCallable
struct RandomNumberGenerator1 {
    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Double {
        let numberOfZeroes = Double(args.first?.value ?? 0)
        let maximum = pow(10, numberOfZeroes)
        return Double.random(in: 0...maximum)
    }
}
/*:
 Esse método pode ser chamado com qualquer numero de parametros, ou possivelmente zero, então nós lemos o primeiro valor cuidadosamente e usamos nil para que haja um padrão de merge sensato.

 Nós podemos agora criar um instancia de `RandomNumberGenerator1` e chamar como uma função:
*/
let random1 = RandomNumberGenerator1()
let result1 = random1(numberOfZeroes: 0)
/*:
 Se você usou `dynamicallyCall(withArguments:)` ao invés – ou ao memsmo tempo, por que você ode ter os dois no mesmo tipo – então você escrevaria isso:
*/
@dynamicCallable
struct RandomNumberGenerator2 {
    func dynamicallyCall(withArguments args: [Int]) -> Double {
        let numberOfZeroes = Double(args[0])
        let maximum = pow(10, numberOfZeroes)
        return Double.random(in: 0...maximum)
    }
}

let random2 = RandomNumberGenerator2()
let result2 = random2(0)
/*:
 Existem algumas regras importantes para se atentar quando usar `@dynamicCallable`:

 - Você pode aplicar isso a structs, enums, classes, e protocols.
 - Se você implementar `withKeywordArguments:` e não implementar `withArguments:`, seu tipo ainda assim pode ser chamado sem nome de parametro – você vai apenas passar strings vazias para as chaves.
 - Se suas implementações de `withKeywordArguments:` ou `withArguments:` estiverem marcadas como throwing, a chamada do método também será throwing.
 - Você pode adicionar `@dynamicCallable` a uma estensão, apenas a definição principal de um tipo.
 - Você ainda assim pode adicionar outros métodos e propriedades ao seu tipo, e stilizá-los normalmente.

 Talvez mais importante, não há suporte para resolução de métodos, o que significa que voc^precisa chamar o tipo diretamente (e.g. `random(numberOfZeroes: 5)`) ao invés de chamar um método específico no tipo (e.g. `random.generate(numberOfZeroes: 5)`). Já existe alguma discussão sobre a adição do último usando uma assinatura de método como este: `func dynamicallyCallMethod(named: String, withKeywordArguments: KeyValuePairs<String, Int>)`.

 Se isso se tornasse possível em versões futuras do Swift, isso poderia abrir algumas possibilidades muito interessantes para mockar testes. Enquanto isso, `@dynamicCallable` não é provável que seja muito popular, mas *é* enormemente importante para uma pequena quantidade de pessoas que querem interoperabilidade com Python, JavaScript, e outras linguagens.
 
 &nbsp;

 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)
 */
