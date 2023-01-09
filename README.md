# Microsoft Teams Call Queue Scheduler

| [Solution overview](https://github.com/OfficeDev/microsoft-teams-apps-call-queue-scheduler/wiki/1.-Solution-overview) |[Deployment guide](https://github.com/OfficeDev/microsoft-teams-apps-call-queue-scheduler/wiki/2.-Deployment) | [Configuration guide](https://github.com/OfficeDev/microsoft-teams-apps-call-queue-scheduler/wiki/3.-Configuration) | [FAQ](https://github.com/OfficeDev/microsoft-teams-apps-call-queue-scheduler/wiki/4.-FAQ) | [Support](https://github.com/OfficeDev/microsoft-teams-apps-call-queue-scheduler/blob/main/SUPPORT.md) |
| ---- | ---- | ---- | ---- | ---- |

This application allows a delegated administrator to manage the active agents for a Microsoft Teams Call Queue in real-time and/or through a defined shift schedule.

![Microsoft Teams Call Queue Scheduler screenshot](./Media/CQS-Home.png)

## About this application

The Teams Admin Center (TAC) has the following limitations:

* granular delegatation capability to allow a defined administration to managed the named agents for a given Call Queue.
* scheduling agents in the Call Queue for specific shifts in the future.

This application provides the following capability:

* Call Queue
    * Select a delegated Call Queue and view the list of named agents that are currently active.
    * Make real-time changes to the list of named agents defined in a Call Queue by a delegated administrator.
    * Schedule agents in shifts to allow for the automation of named agents in the Call Queue by a delegated administrator.
        * Schedule agents in advance by uploading a CSV file.
        * Modify an existing shift schedule
            * add an agent to the existing schedule
            * remove an agent from the existing schedule
            * modify the shift of a scheduled agent.

This application works by manipulating the list of named agents in a Call Queue.  This application does NOT support agents defined as part of a group or a Team channel.  Since this application leverages named agents, the number of agents that can be active in the queue at the same time is limited to 20.  The number of agents that could be potentially added to the queue can be much greater.  

Note: this application does not have an error handling to account for the case where the 21st or greater agent is added to the queue. 

See Step 3: Set up who will answer incoming calls [here](https://learn.microsoft.com/en-us/microsoftteams/create-a-phone-system-call-queue#steps-to-create-a-call-queue) for detail on the different ways agents can be defined to answer calls. 

The architecture of this solution can be adapted to support other scenarios that require delegated admin management of Teams phone system or any other feature accessible via PowerShell cmdlet or even MS Graph API. 

Here is the application running in Microsoft Teams

<!-- <p align="center">
    <img src="./Media/AAandCQManagement.jpg" alt="Microsoft Teams AA/CQ Orchestrator screenshot" width="600"/>
</p> -->

![Microsoft Teams Call Queue Scheduler screenshot](./Media/CQS-Schedule.png)

If you want to start using the solution yourself review the Wiki for the deployment and configuration steps.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
