// Importing flowtoken and fungible token to use different useful interfaces and methods
import FungibleToken from 0x01
import FlowToken from 0x02



//This contract will be deployed from FundCustodyProvider's account
pub contract EducationFund {


///////////////// events to emit //////////////
pub event withdraw(amount:UFix64)

// Parent to update the configurations
// Since this environment does not support getCurrentBlock().timestamp, in this test environment
pub resource interface Update {
        pub fun UpdateConf(withdrawLimit: UFix64)
    }

pub resource interface getbal {
access(all) fun getFundBalance(): UFix64
}


// Custody Admin resource created by custody provider to manage the fund
pub resource FundManager: getbal, Update, FungibleToken.Receiver, FungibleToken.Provider {
        

        // creating vault field of type Capability-FlowToken.Vault 
        pub var vault: Capability<&FlowToken.Vault>

        //withdraw limit
        pub var withdrawLimit: UFix64

        //withdraw time ( not implemented due to no timestamp support )
        //pub var withdrawTime: UInt

        // intial balance
        //pub var balance: UFix64


        init(vault: Capability<&FlowToken.Vault>) {
            self.vault = vault
            //self.balance = 5.0
            self.withdrawLimit = 5.0
            //self.withdrawTime = 0
        }

        // FungibleToken.Receiver actions

        /// Deposits tokens to the vault
        access(all) fun deposit(from: @FungibleToken.Vault) {
            self.depositToken(from: <-from)
        }

        access(self) fun depositToken(from: @FungibleToken.Vault) {
            let this_vault = self.vault.borrow()!

            let balance = from.balance

            this_vault.deposit(from: <- from)

        }


        /// Withdraws  tokens from the vault
       access(all) fun withdraw(amount: UFix64): @FungibleToken.Vault {
            return <-self.withdrawFund(amount: amount)
        }

        access(self) fun withdrawFund(amount: UFix64): @FungibleToken.Vault {
            
            // Once the requirements below is met then function can move forward with execution
            pre {
                self.withdrawLimit >= amount: "Amount exceeds, please enter below accepted amount"
                //self.withdrawTime >= g÷etCurrentBlock().height
            }


            // After withdraw is done adjust the balance.
           // post {
              //  self.withdrawLimit == before(self.withdrawLimit) - amount: "Please review the amount"
           // }

            let fundVault = self.vault.borrow()! // this borrow is from flowtoken resource vault

            let withdrawVault <- fundVault.withdraw(amount: amount) // this withdraw function is from flowtoken withdraw method

            
            return <- withdrawVault
        }


       access(all) fun getFundBalance():UFix64 {
            let vaultRef = self.vault.borrow()!
            return vaultRef.balance
        }

        pub fun UpdateConf(withdrawLimit: UFix64) {
            self.withdrawLimit = withdrawLimit
            //self.withdrawTime = newWithdrawTime
            //emit Updated( Limit: self.withdrawLimit)

        }


    }


   //////////////////// Create Beneficiary resource /////////////////



pub resource interface WithdrawFundToSelf {
    pub fun withdrawfund(amount:UFix64): @FungibleToken.Vault
    //pub fun getLockedAccountBalance(): UFix64
    }

pub resource interface AddCapability {
        pub fun addCapability(cap: Capability<&FundManager{EducationFund.getbal}>)
        pub fun checkCap(): String
}
        
        
pub resource Beneficiary :  AddCapability, WithdrawFundToSelf{

        /// Capability that is used to access the Custody Fund account
       
        access(contract) var capability: Capability<&FundManager{EducationFund.getbal}>?

       
        pub fun addCapability(cap: Capability<&FundManager{EducationFund.getbal}>) 
        {
            pre {
               
                // validating the existence of the capability before executing the method
                cap.borrow() != nil: "could not borrow a reference"
                self.capability == nil: "resource already exists"
            }
            // add the Capability to beneficiary
            self.capability = cap
        }

        access(contract) var fundManager: Capability<&FundManager{FungibleToken.Provider}>


       access(self) fun borrowfundManager(): &FundManager{FungibleToken.Provider} {
            return self.fundManager.borrow()!
        }


        /// Returns the locked account balance for this token holder.
        pub fun withdrawfund(amount:UFix64): @FungibleToken.Vault {
            emit withdraw(amount:amount)
            return <- self.borrowfundManager().withdraw(amount: amount)
            
        }

        // Optional capability receiver
        pub fun checkCap(): String {
        pre {
                // The transaction will revert if capability does not exist
               self.capability != nil: "Don't have the capability"
            }

            return "Capability Received"
         }
             init(fundManager: Capability<&FundManager{FungibleToken.Provider}>) {
               self.capability = nil
               self.fundManager = fundManager
       }

       }








/////////////////////////////////  Parent resource and actions ///////////////// //////////////////////


pub resource interface AddUpadateCapability {
        pub fun UpdateFundConf(Limit:UFix64)
}

pub resource Parent : AddUpadateCapability {

    access(contract) var fundManagerUpdate: Capability<&FundManager{Update}>


    access(self) fun borrowfundManager(): &FundManager{Update} {
            return self.fundManagerUpdate.borrow()!
        }

    pub fun UpdateFundConf(Limit:UFix64) {
            return self.borrowfundManager().UpdateConf(withdrawLimit:Limit)
        }

    init (fundManagerUpdate: Capability<&FundManager{Update}>) {

        self.fundManagerUpdate=fundManagerUpdate

    }
          


}

///////////////////////////// Public functions to create resources /////////////////////////////


pub fun createFundManager(vault: Capability<&FlowToken.Vault>): @FundManager {
    return <- create FundManager(vault:vault)

}


 // create new beneficiary resource for auth account
    pub fun createBeneficiary(fundManager: Capability<&FundManager{FungibleToken.Provider}>): @Beneficiary {
        return <- create Beneficiary(fundManager:fundManager)
    }

    // public function to create resources. this on to create lockedaccount creator
    pub fun createParentResource(fundManagerUpdate: Capability<&FundManager{Update}>): @Parent {
        return <-create Parent(fundManagerUpdate: fundManagerUpdate)
    }

//////////////////////////////. init singleton ///////////////


   // Path to store the fund manager resource in custody account
    pub let FundManagerStoragePath: StoragePath
    pub let FundManagerPrivatePath: PrivatePath
    pub let FundManagerPublicPath: PublicPath


    // Path to create and store FlowToken Vault for the fund
    pub let FlowFundTokenVaultStoragePath: StoragePath
    pub let FlowFundTokenVaultPublicPath: PublicPath
    pub let FlowFundTokenVaultPrivatePath: PrivatePath

    // Path for Child resource
    pub let ChildCapabilityReceiverStoragePath: StoragePath
    pub let ChildCapabilityPublicPath: PublicPath
    pub let ChildWithdrawPrivatePath: PrivatePath

    // path for depositor resource
    pub let DepositorStoragePath: StoragePath
    pub let DepositorPublicPath: PublicPath

    //  Path for Parent resource
    pub let ParentStoragePath: StoragePath
    pub let ParentCapPublicPath: PublicPath
    pub let ParentUpdatePrivatePath: PrivatePath



init() {

        self.FundManagerStoragePath = /storage/fundManager
        self.FundManagerPublicPath = /public/fundManagerPublic
        self.FundManagerPrivatePath = /private/fundManagerPrivate


        self.FlowFundTokenVaultStoragePath = /storage/flowTokenVault
        self.FlowFundTokenVaultPublicPath = /public/flowtokenPublic
        self.FlowFundTokenVaultPrivatePath = /private/flowTokenVaultPrivate

        
        self.ChildCapabilityReceiverStoragePath = /storage/capabilityStorage
        self.ChildCapabilityPublicPath = /public/capRecieverPublic
        self.ChildWithdrawPrivatePath = /private/withdrawPrivate

        
        self.ParentStoragePath = /storage/ParentResourceStorage
        self.ParentCapPublicPath = /public/parentUpdatePublic
        self.ParentUpdatePrivatePath = /private/parentUpdatePrivate

        self.DepositorStoragePath = /storage/DepositorStorage
        self.DepositorPublicPath = /public/DepositorPublic
        


//create flowvault token
self.account.save(<-FlowToken.createEmptyVault(), to: /storage/flowTokenVault)

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        self.account.link<&FlowToken.Vault{FungibleToken.Receiver}>(
            /public/flowTokenReceiver,
            target: /storage/flowTokenVault
        )

        self.account.link<&FlowToken.Vault{FungibleToken.Provider}>(
        /private/flowTokenwithdrawer,
        target: /storage/flowTokenVault)
}

}
