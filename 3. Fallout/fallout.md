Ici on nous demande d'acquérir la propriété du contrat.

En lisant chaque fonction, on se rend compte simplement que la fonction qui va permettre de changer la propriété du contrat est `Fal1out()`.

## Pourquoi ?

La fonction est presentée comme étant une fonction constructor.
#
Or, un constructor c'est soit :

```
constructor() public {
  /// mon code qui doit être executé dès la création du contrat
}
```
ou alors :

```
contract monContrat {
  function monContrat {
    /// mon code qui doit être executé dès la création du contrat
  }
}
```

Dans la deuxième solution, la fonction a le même nom que le contrat, cela permet au compilateur de comprendre que c'est le constructor et qu'il faut l'exécuter dès la création..

Revenons à notre code:


En l'occurence, la fonction Fal1out() ne s'est pas executée à la création du contrat étant donné qu'il y a une erreur dans le nom de ce constructor : c'est un chiffre 1 au lieu d'une lettre l qui est utilisé.


-> Résultat, ça ne s'est pas executé et c'est une simple fonction. De ce fait, n'importe qui peut exécuter cette fonction pour devenir owner du contrat ! :)

Fal1out est une fonction publique et payable, du coup on peut lui envoyer des fonds.
Cette fonction :
- Transforme le msg.sender en owner,
- Met le montant envoyé dans le mapping allocation

Ce qui nous intéresse est que la fonction transforme le msg.sender en owner.

Il suffit donc d'appeler cette fonction en lui envoyant des fonds pour récupérer la propriété du contrat:

```
contract.Fallout(sendTransaction({value: 1}));
```

pour vérifier qu'on est bien le owner, on peut écrire ça dans la console du navigateur :

```
await contract.owner()
```
