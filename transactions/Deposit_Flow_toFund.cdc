import FungibleToken from 0x01
import FlowToken from 0x02
import EducationFund from 0x03

transaction(amount: UFix64) {

    
    var vaultref: @FungibleToken.Vault

    prepare(signer: AuthAccount) {
    //var depositRef: &EducationFund.FundManager

        //self.depositRef = signer.borrow<&EducationFund.FundManager{FungibleToken.Receiver}>(from: EducationFund.FundManagerPublicPath)

       
    let vault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow flow token vault ref")

       self.vaultref <- vault.withdraw(amount:amount)


        //self.vaultRef = signer.borrow<&FlowToken.Vault>(from: EducationFund.FlowFundTokenVaultPublicPath)
            //?? panic("Could not borrow flow token vault ref")
    }

    execute {

                    let recipient = getAccount(0x03)

                      // get the recipient's Receiver reference to their Vault
                      // by borrowing the reference from the public capability
                    let receiverRef = recipient.getCapability<&EducationFund.FundManager{FungibleToken.Receiver}>
                    (EducationFund.FundManagerPublicPath).borrow()
                                        ?? panic("Could not borrow a reference to the receiver")

                      log("got capability")

                      //let depositRef = getAccount(0x03).getCapability<&EducationFund.FundManager{FungibleToken.Receiver}>
                        // (EducationFund.FundManagerPublicPath)
                        //                  .borrow()
                            //            ?? panic("Could not borrow a reference to capability")
                          
                      receiverRef.deposit(from: <-self.vaultref) 
                      log("done")
                          //?? panic ("no flow token in this account")
                      
            }

    // post {

    //getAccount(0x03).getCapability<&EducationFund.FundManager>
       // (EducationFund.FundManagerPublicPath)
                 //       .check(): "not found"
    //}
}