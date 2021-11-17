import FungibleToken from 0x01
import FlowToken from 0x02
import EducationFund from 0x03



transaction(childaccnt: Address) {


    prepare(signer: AuthAccount) {

        let childac = getAccount(childaccnt)

        let getBalanceCap = signer
            .getCapability<&EducationFund.FundManager{EducationFund.getbal}>
            
            (EducationFund.FundManagerPrivatePath)
            log("got check balance cap")

        log(childac.getCapability
            <&EducationFund.Beneficiary{EducationFund.AddCapability}>
            (EducationFund.ChildCapabilityPublicPath)
            .check())
            
        let capabilityReceiver = childac.getCapability
            <&EducationFund.Beneficiary{EducationFund.AddCapability}>
            (EducationFund.ChildCapabilityPublicPath)
            .borrow() ?? panic("Could not borrow capability receiver reference")
log("got receiver")
        



        capabilityReceiver.addCapability(cap: getBalanceCap)




    }
}