# MacMasters

[English](README.md) · [Español](README.es.md) · **Português**

Um app gratuito e não oficial para jogar **Digimon Masters Online** no macOS. Você abre, instala o jogo uma vez e joga. Não precisa de licença do CrossOver nem de Windows.

> Projeto não oficial, sem relação com Move Games, Gameking, Bandai Namco ou CodeWeavers. Leia os termos de serviço do jogo antes de usar: você joga por sua conta e risco.

## O que o app faz

DMO é um jogo de Windows. O app traz o [Wine](https://www.winehq.org/), uma camada de compatibilidade gratuita que roda programas de Windows no macOS, e o configura só para o DMO:

1. **Cria um ambiente Windows privado** para o jogo na sua pasta de usuário, separado de todo o resto do seu Mac.
2. **Baixa um componente do Windows direto da Microsoft** na primeira vez: o DirectX (100 MB), que o jogo usa para os gráficos. O download é conferido pela impressão digital do arquivo (SHA-256).
3. **Instala o jogo** com o instalador oficial que você baixa em [dmo.gameking.com](https://dmo.gameking.com/Main/Main.aspx), ou copia do CrossOver se você já tiver o jogo lá.
4. **Abre o launcher do próprio jogo**, que atualiza o jogo e deixa você entrar na sua conta como sempre.

Ele também traz duas correções no Wine que o DMO precisa no Mac. Sem elas, o jogo mostra "Falha ao receber dados de recursos" ao entrar no mundo e trava ao ser fechado.

## O que o app não faz

- **Não** modifica o jogo, os arquivos dele nem o anti-cheat XIGNCODE.
- **Não** roda outros programas de Windows: só abre o DMO.
- **Não** coleta nem envia dados. Os únicos downloads são o DirectX da Microsoft e o que o próprio jogo baixa.
- **Não** inclui o jogo nem arquivos da Microsoft: cada jogador baixa dos sites oficiais.

## Requisitos

- Um Mac com Apple Silicon (M1 a M4) ou Intel, com macOS 11 ou posterior.
- Rosetta 2 em Macs com Apple Silicon. Se não estiver instalado, o app oferece instalar.
- Cerca de 30 GB livres no disco para o jogo.

Testado em um Apple M4 com macOS 26.5.2. Se você testar em outro Mac, conte como foi em uma issue.

## Instalar e jogar

1. Baixe `MacMasters-<versão>.dmg` em [Releases](../../releases), abra o arquivo e arraste **MacMasters** para a pasta **Applications** (Aplicativos).
2. Abra o app. Na primeira vez, o macOS bloqueia porque ele não é notarizado pela Apple. Vá em **Ajustes do Sistema → Privacidade e Segurança**, role até o aviso sobre "MacMasters" e clique em **Abrir Mesmo Assim**.
3. As mensagens do app ainda estão em espanhol. Clique em **Continuar** para baixar o DirectX e preparar o ambiente (cerca de um minuto).
4. Escolha como obter o jogo:
   - **Instalar de nuevo** (instalar de novo): baixe o instalador oficial em [dmo.gameking.com](https://dmo.gameking.com/Main/Main.aspx) e selecione o arquivo. Ao terminar, o launcher do jogo baixa as últimas atualizações, o que pode demorar.
   - **Usar la de CrossOver** (usar a do CrossOver): só aparece se você já tiver o DMO em um bottle do CrossOver chamado `DMO`. A cópia é instantânea e não ocupa espaço extra.
5. Entre na sua conta e jogue. Daí em diante, abrir o app leva direto ao launcher do jogo.

## Problemas comuns

| O que aparece | O que fazer |
| --- | --- |
| "Não é possível abrir MacMasters" | Autorize em **Ajustes do Sistema → Privacidade e Segurança → Abrir Mesmo Assim** (passo 2). |
| Fechar o jogo leva cerca de 20 segundos | É normal: o jogo salva as configurações, desconecta e fecha o anti-cheat. |
| Qualquer outro problema | Abra uma issue e anexe `~/Library/Logs/MacMasters/launcher.log`. |

## Desinstalar

Apague o app e estas pastas (no Finder: **Ir → Ir para a Pasta…**):

| Pasta | Conteúdo |
| --- | --- |
| `~/Library/Application Support/MacMasters` | O ambiente Windows com o jogo |
| `~/Library/Caches/MacMasters` | O download do DirectX |
| `~/Library/Logs/MacMasters` | O registro |

## Para desenvolvedores

Como o app funciona por dentro, as correções no Wine, como compilar e as licenças, em inglês: [docs/technical.md](docs/technical.md).

## Licença

O código do app usa a licença MIT. O Wine e os outros componentes incluídos mantêm suas licenças: veja [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
