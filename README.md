<div align="center">

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:43C6AC,100:F8FFAE&height=200&section=header&text=SwiftUI%20%2B%20HealthKit%20Tracker&fontSize=45&fontColor=fff&animation=twinkling&fontAlignY=40">

<p align="center">
  <i>Aplicativo de rastreamento de saúde usando SwiftUI e integração com o HealthKit da Apple. Veja passos, calorias, distância e muito mais.</i>
</p>

<p align="center">
  <i> Health tracking app built with SwiftUI and integrated with Apple HealthKit — displaying steps, calories, distance and more.</i>
</p>

---

###  Features | Funcionalidades

<div align="center">

| Feature | Description                                 | Descrição                                              |
| :-----: | :------------------------------------------ | :----------------------------------------------------- |
|   ❤️    | Integration with Apple HealthKit             | Integração com Apple HealthKit                         |
|   👣    | Step count tracking                          | Rastreamento de passos                                |
|   🔥    | Calories burned display                      | Exibição de calorias queimadas                        |
|   📏    | Distance tracking                            | Medição de distância percorrida                       |
|   ⏱️    | Active energy and workout duration           | Energia ativa e duração de atividades                 |
|   📊    | Real-time data refresh                       | Atualização dos dados em tempo real                   |
|   🧩    | Modular and reusable components              | Componentes reutilizáveis e bem organizados           |

</div>

---

###  Technologies | Tecnologias

| Tipo      | Ferramenta/Framework | Descrição                                                     |
| --------- | ---------------------| -------------------------------------------------------------- |
| 🍎 Apple | `Xcode + SwiftUI`     | Interface declarativa e reativa                                |
| 📈 Apple | `HealthKit`           | Leitura de dados de saúde do usuário com permissões seguras   |
| ⏳ Swift | `DateComponents`      | Conversão de datas para diferentes unidades de tempo           |

---

###  Estrutura do Projeto

- `HealthManager.swift`: gerenciamento de permissões e leitura dos dados do HealthKit
- `HealthDataViewModel.swift`: view model que comunica os dados para a interface
- `ContentView.swift`: tela principal com as métricas de saúde do usuário
- `HealthStatView.swift`: componente visual reutilizável para exibir métricas (passos, calorias etc.)
- `Extensions.swift`: utilitários para formatação de datas e unidades
- `Model`: abstrações e estruturas relacionadas aos dados de saúde

---

### Executando o Projeto

1. Clone o repositório:
```bash
git clone https://github.com/J040VRM/HealthKit.git
```

2. Abra o projeto no Xcode:
```bash
open HealthKit.xcodeproj
```

3. Vá até `Signing & Capabilities` e:
   - Ative o **HealthKit**
   - Defina seu **Team ID**
   - Certifique-se de que está usando um **dispositivo real** (HealthKit não funciona no simulador)

4. Compile e rode o app no seu iPhone.

---

### Permissões Necessárias

- O app solicita permissão para ler os seguintes dados do HealthKit:
  - Passos (`stepCount`)
  - Calorias Ativas (`activeEnergyBurned`)
  - Distância Caminhada/Corrida (`distanceWalkingRunning`)
  - Tempo de Exercício (`appleExerciseTime`)
  - Tempo em Pé (`appleStandTime`)

---

###  Observações

- O HealthKit só funciona em **dispositivos físicos**.
- Certifique-se de permitir o acesso no app **Saúde** da Apple.
- O projeto é uma base para qualquer app que deseje integrar estatísticas de saúde no iOS.

---


</div>
