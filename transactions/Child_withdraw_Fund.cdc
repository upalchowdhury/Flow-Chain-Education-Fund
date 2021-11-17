import FungibleToken from 0x01
import FlowToken from 0x02
import EducationFund from 0x03


transaction(amount: UFix64) {

    prepare(acct: AuthAccount) {
       let withdrawRef = acct.getCapability
       <&EducationFund.Beneficiary{EducationFund.WithdrawFundToSelf}>
       (EducationFund.ChildWithdrawPrivatePath).borrow()
            ?? panic("Could not borrow a reference to Fund")
           // log("capability cant be borrowed")

    // flow token vault for storing toke or move it to admin transactions
    let FlowVault = acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
    

    if FlowVault.check()==false{
      acct.save(<-FlowToken.createEmptyVault(), to: /storage/flowTokenVault)
      } else {
        log ("FlowToken vault exists will use it to get tokens")}
      
       
        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        acct.link<&FlowToken.Vault{FungibleToken.Receiver}>(
            /public/flowTokenReceiver,
            target: /storage/flowTokenVault
        )

    let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow flow token vault ref")
    
     vaultRef.deposit(from: <- withdrawRef.withdrawfund(amount: amount))
    }

    execute {
    
      //self.vaultRef.deposit(from: <- self.withdrawRef.withdraw(amount: amount))
    } 

    
    }
