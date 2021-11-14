// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/*

Commandes utiles pour la console navigateur Ethernaut :
Voir notre balance :
  (await contract.balanceOf(player)).toString()

Voir l'adresse du contrat Ethernaut :
  contract.address
  
*/


/*


/!\ J'explique le code avec des uint8 et non avec des uint256, car plus simple à expliquer et comprendre /!\
/!\ car uint256 max = 115792089237316195423570985008687907853269984665640564039457584007913129639935
/!\ et uint8 max = 255

-- ANALYSE --

On fait face à un contrat Token qui permet à un utilisateur d'envoyer son token à une autre adresse.
En l'occurence ici, Ethernaut nous explique que le constructor sera lancé avec un initialSupply de 20.
On se retrouve donc avec notre adresse personnelle disposant de 20 tokens.
Le but est d'obtenir des tokens de ce contrat en trouvant une faille.

En inspectant le contrat, on se rend compte que l'on n'utilise pas SafeMath,
Donc les uint ne sont pas protégés de base contre les overflows et underflows.


La fonction transfer prend en argument une adresse _to et un uint _value :

1.  require(balances[msg.sender] - _value >= 0);
    Requiert que la balance du (msg.sender - valeur indiquée en paramètre) soit supérieure ou égale à 0
   
    -> On ne pourrait donc pas transférer davantage que ce que l'on dispose en tokens
    Exemple1: transfer(adresseX, 19) -> 20 - 19 = 1 -> Donc le require est validé
    Exemple2: transfer(adresseX, 20) -> 20 - 20 = 0 -> Donc le require est validé
    Exemple3: transfer(adresseX, 21) -> 20 - 21 = -1 -> Donc le require serait invalidé ? Non, il serait validé.. car ca ne fait pas - 1
    
    En analysant l'Exemple3 avec le code actuel, on se rend compte que :
    - Nous utilisons des uint, de ce fait il est impossible d'obtenir des nombres négatifs.
      De ce fait, en exécutant l'Exemple3, on se retrouverait donc avec 20 - 21 = 255
      En effet, vu que uint8 min = 0 et uint8 max = 255, si on soustrait 1 de 0, ça donne 255.
      Inversement, si on ajoute 1 à 255, ça donne 0.
      (Tout comme une horloge passe de 23:59 à 00:00 et non pas à 24:00)
      
/!\ J'explique le code avec des uint8 et non avec des uint256, car plus simple à expliquer et comprendre /!\

2.  balances[msg.sender] -= _value;
    Soustrait _value de la balance du msg.sender.
    
    Exemple1: 20 - 19 = 1
    Exemple2: 20 - 20 = 0
    Exemple3: 20 - 21 = 255
    
    Même explication, on utilise le problème des underflows pour exploiter le contrat

3.  balances[_to] += _value;
    Ajoute _value à la balance de l'adresse _to.
    
    Exemple1: 0 + 19 = 19
    Exemple2: 0 + 20 = 20
    Exemple3: 0 + 21 = 21
    
    
Attaque : cf contrat Attack ci-dessous.

*/
contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}

/*
-- ATTAQUE --
/!\ J'explique le code avec des uint8 et non avec des uint256, car plus simple à expliquer et comprendre /!\

Ci-dessus, on a vu l'exemple si msg.sender était notre wallet direct. Cependant, nous allons utiliser un contrat Attack.
Donc notre msg.sender aura une balance de tokens égale à 0, vu que ce sera l'adresse de notre contrat Attack:
Notre wallet perso (tx.origin) -> Contrat Attack (msg.sender) -> Contrat Token

-> VOIR 4.TELEPHONE pour comprendre la différence entre msg.sender et tx.origin

De ce fait, voici notre exemple encore, mais cette fois-ci avec un msg.sender qui n'a pas de tokens, donc notre situation: 

    Exemple1: transfer(notreAdresse, 1) -> 0 - 1 = 255 -> Donc le require est validé
    Exemple2: transfer(notreAdresse, 2) -> 0 - 2 = 254 -> Donc le require est validé
    Exemple3: transfer(notreAdresse, 235) -> 0 - 235 = 20 -> Donc le require est validé

On a donc simplement à appeler la fonction transfer avec (uint max - balance = 255 - 20 = 235) comme valeur.
De ce fait, lorsque la fonction transfer fera -> balances[_to] += _value;
Cela nous fera : 20 += 235 = 255
Du coup, on aura le montant de tokens le plus élevé possible (uint8 max).

Si nous détaillons, cela donnerait:

1.  balances[msg.sender] -= _value;
    balances[adresseAttack] -= 235 -> 0 - 235 = 20 
    //l'underflow provoque ça selon ce qu'on lui soustrait, exemple -> 0 - 1 = 255; 0 - 20 = 235; 0 - 100 = 155; 0 - 200 = 55; 0 - 235 = 20
    
2.  balances[_to] += _value;
    balances[monAdresse] += 235 -> 235 + 20 = 255.

/!\ J'explique le code avec des uint8 et non avec des uint256, car plus simple à expliquer et comprendre /!\
    
Du coup, étant donné qu'on est en uint256, on va pas faire uint8 max - balance (255 - 20)
Mais plutot uint256max - balance (115792089237316195423570985008687907853269984665640564039457584007913129639935 - 20)

Ce qui donne donc : 115792089237316195423570985008687907853269984665640564039457584007913129639915


On aura donc ensuite une balance de token de :

115792089237316195423570985008687907853269984665640564039457584007913129639935 tokens

car on aura une balance de 20 + 115792089237316195423570985008687907853269984665640564039457584007913129639915



*/

contract Attack {
    address public targetContract;
    
    constructor (address _targetContract) public { // Au déploiement, ça demandera l'adresse du contrat Token
        targetContract = _targetContract;
    }
    function hack(address _to, uint _value) public { //Notre simple fonction hack qui appelle la fonction transfer du contrat Token
        Token(targetContract).transfer(_to, _value); //avec l'adresse et la valeur qu'on lui donne
    }
}

/*
Conclusion :
-> Toujours faire attention aux underflows et overflows.
-> Pour cela, il existe la librairie SafeMath qui va permettre de tenir compte de ces problématiques
-> Cette librairie va renvoyer des erreurs et arreter l'exécution du code en cas d'underflow/overflow.
*/
