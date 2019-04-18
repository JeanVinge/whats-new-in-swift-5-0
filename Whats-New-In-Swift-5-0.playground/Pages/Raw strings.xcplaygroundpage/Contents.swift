/*:
 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)

 ## Raw strings
 [SE-0200](https://github.com/apple/swift-evolution/blob/master/proposals/0200-raw-string-escaping.md) adicionado habilidade de criar *raw strings*, onde barras invertidas e aspas são interpretadas como simbolos literais ao inves de *characters* de *escape*. Isso faz com que o número de caso de uso seja mais facil, portanto expressões regulares irão se beneficiar.

 Para usar *raw strings*, coloque um ou mais `#` antes da sua string, como abaixo:
*/
    let rain = #"A "chuva" na "Espanha" cai principalmente sobre os Espanhóis"#
/*:
 Os `#` do inicio e ao final tornam-se parte de delimitadores da string, então o Swift entende que as aspas em torno de “chuva” e “Espanha” deveriam ser tratadas como marcas de citações literais em vez de terminador da string.

 *Raw strings* também aceita usar barras invertidas:
*/
    let keypaths = #"Keypaths como \Person.name mantem referencia de propriedades."#
/*:
 Deste modo a barra invertida é tratada como um *literal character* na string, ao inves de *character* de *escape*.
*/

    let answer = 42
    let dontpanic = #"A resposta da vida, do universo, e de tudo é \#(answer)."#

/*:
 Observe como é usado `\#(answer)` para reconhecer a *string interpolation* - uma `\(answer)` regular será interpretada como character na string, então quando você quer que aconteça a *string interpolation* voce adiciona um `#` extra.

 Um dos recursos interessantes de *raw strings* do Swift é o uso de símbolos de hash no início e no final, pois você pode usar mais de um no caso improvável de ser necessário. É difícil fornecer um bom exemplo aqui, porque realmente deveria ser extremamente raro, mas considere esta sequência: **Meu cachorro disse "woof" #gooddog**.
 Como não há espaço antes do hash, o Swift verá `#` e imediatamente o interpretará como o terminador de string. Nesta situação, precisamos alterar nosso delimitador de `#` para `##`, desta forma:
*/
    let str = ##"Meu cachorro falou "woof"#gooddog"##
/*:

 Observe como o número de simbolos de hashes no final deve corresponder ao número do início.
     As strings raw são totalmente compatíveis com o sistema de strings multi-line - apenas use `"""#` para iniciar e depois `"""#` no final, assim:
*/
    let multiline = #"""
    A resposta da vida,
    do universo,
    e de tudo é \#(answer).
    """#
/*:

 Ser capaz de fazer expressões regulares sem muitas barras invertidas será particularmente útil. Por exemplo, escrever um regex simples para localizar *keypaths* como `\Person.name`, costumava ficar assim:
*/
    let regex1 = "\\\\[A-Z]+[A-Za-z]+\\.[a-z]+"
/*:
 Graças a *raw strings*, podemos escrever a mesma coisa com metade do número de barras invertidas:
*/
    let regex2 = #"\\[A-Z]+[A-Za-z]+\.[a-z]+"#
/*:
 Ainda precisamos de *algumas*, porque expressões regulares também os usam.
 
 &nbsp;

 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)
 */
