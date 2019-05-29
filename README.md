
# mein.elba.raiffeisen.at

Zugriff auf deine Bankdaten bei Raiffeisen Österreich.

## Beispiel

- Bank: `Raiffeisen Burgenland` ⇢ `ELVIE33V`
- Verfüger: `0V987654`
- PIN: `12345`

> ./meinkonto.rb ELVIE33V0V987654 12345


## Mandanten

> https://sso.raiffeisen.at/api/quer-kunde-login/kunde-login-ui-services/rest/config/mandanten/?bankengruppe=rbg

```
[{
    "code": "rbgooe",
    "verfuegerKennung": "ELOOE01V",
}, {
    "code": "rbgooebd",
    "verfuegerKennung": "ELOOE01V",
}, {
    "code": "rbgooepb",
    "verfuegerKennung": "ELOOE01V",
}, {
    "code": "rbgk",
    "verfuegerKennung": "ELOOE03V",
}, {
    "code": "rbgsbg",
    "verfuegerKennung": "ELOOE05V",
}, {
    "code": "rbgt",
    "verfuegerKennung": "ELOOE11V",
}, {
    "code": "rbgtjh",
    "verfuegerKennung": "ELOOE11V",
}, {
    "code": "rbgbgld",
    "verfuegerKennung": "ELVIE33V",
}, {
    "code": "rbgvlbg",
    "verfuegerKennung": "ELVIE37V",
}, {
    "code": "rbgstmk",
    "verfuegerKennung": "ELVIE38V",
}, {
    "code": "rbgnoew",
    "verfuegerKennung": "ELVIE32V",
}, {
    "code": "zveza",
    "verfuegerKennung": "ELVIE91V",
}]
```