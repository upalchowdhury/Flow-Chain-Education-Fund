import FungibleToken from 0x01
import FlowToken from 0x02
import EducationFund from 0x03


transaction() {

    prepare(signer: AuthAccount, childac: AuthAccount, parentac: AuthAccount) {

//////////////////////. Custody provider actions ////////////////////////////

    let vaultCapability = signer
            .link<&FlowToken.Vault>(/private/flowTokenVault, target: /storage/flowTokenVault)
            ?? panic("Could not link Flow Token Vault capability")

    let fund <- EducationFund.createFundManager(vault: vaultCapability)
        // create a fund manager and store it in the custody account
    signer.save(<- fund, to: EducationFund.FundManagerStoragePath)

    // allowing anyone to deposit
    signer.link<&EducationFund.FundManager{FungibleToken.Receiver}>(
            EducationFund.FundManagerPublicPath,
            target: EducationFund.FundManagerStoragePath
        ) ?? panic("Capability not accessible")
     

        // Create a link to private capabilities for withdraw
      let withdrawCap = signer.link<&EducationFund.FundManager{EducationFund.getbal,FungibleToken.Provider}>(
            EducationFund.FundManagerPrivatePath,
            target: EducationFund.FundManagerStoragePath
        ) ?? panic("Capability not accessible")

        // Create a link to private capabilities for checking the balance
        let checkBalCap = signer.link<&EducationFund.FundManager{EducationFund.getbal}>(
            /private/getbalcap,
            target: EducationFund.FundManagerStoragePath
        ) ?? panic("Capability not accessible")

   
   // Create private link for update config 
    let updateConfCap = signer.link<&EducationFund.FundManager{EducationFund.Update}>(
            /private/UpdateconfigPath,
            target: EducationFund.FundManagerStoragePath
        ) ?? panic("Capability not accessible")



    //////////////////////. Child's fund withdraw actions and check balance actions ////////////////////////////


    let childfunc <- EducationFund.createBeneficiary(fundManager:withdrawCap)

     childac.save( <- childfunc, to: EducationFund.ChildCapabilityReceiverStoragePath)



     // link public capability

     childac.link<&EducationFund.Beneficiary{EducationFund.AddCapability}>(
            EducationFund.ChildCapabilityPublicPath,
            target: EducationFund.ChildCapabilityReceiverStoragePath
        )
    // link private withdraw cap
    childac.link<&EducationFund.Beneficiary{EducationFund.WithdrawFundToSelf}>(
            EducationFund.ChildWithdrawPrivatePath,
            target: EducationFund.ChildCapabilityReceiverStoragePath
        )

    log(childac.getCapability
            <&EducationFund.Beneficiary{EducationFund.AddCapability}>
            (/public/addcappath)
            .check())

    log(childac.getCapability<&EducationFund.Beneficiary{EducationFund.WithdrawFundToSelf}>(
            EducationFund.ChildWithdrawPrivatePath).check())

    
    
    //////////////////////. Parent's update actions ////////////////////////////

    let parentfunc  <- EducationFund.createParentResource(fundManagerUpdate: updateConfCap)
    parentac.save(<- parentfunc, to: EducationFund.ParentStoragePath)

    parentac.link<&EducationFund.Parent{EducationFund.AddUpadateCapability}>(
            EducationFund.ParentUpdatePrivatePath,
            target: EducationFund.ParentStoragePath
        )





        }

    }