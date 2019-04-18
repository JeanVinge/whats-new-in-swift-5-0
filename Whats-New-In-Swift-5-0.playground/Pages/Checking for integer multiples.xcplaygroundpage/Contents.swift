/*:
 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)

 ## Checking for integer multiples

 [SE-0225](https://github.com/apple/swift-evolution/blob/master/proposals/0225-binaryinteger-iseven-isodd-ismultiple.md) adiciona o método `isMultiple(of:)` para inteiros, nos permitindo checkar quando um numero é multiplo de outro de uma forma muito mais clara do que usando o resto da divisão, com o operador `%`.

 Por exemplo:
*/
    let rowNumber = 4
    
    if rowNumber.isMultiple(of: 2) {
        print("Even")
    } else {
        print("Odd")
    }
/*:
 Sim, nos podemos escrever a mesma checkagem  usando `if rowNumber % 2 == 0` mas você tem que adimitir que é menos limpo – ter `isMultiple(of:)` como um método significa que ele pode ser listado no code completion do Xcode, que ajuda encontrá-lo.
 
 &nbsp;

 [< Anterior](@previous)           [Home](Introduction)           [Próximo >](@next)
 */
