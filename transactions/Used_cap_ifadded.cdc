import FungibleToken from 0x01
import FlowToken from 0x02
import EducationFund from 0x03

transaction {


    prepare (signer:AuthAccount) {

            let addedCap = signer.getCapability<&EducationFund.Beneficiary{EducationFund.AddCapability}>
            (EducationFund.ChildCapabilityPublicPath).borrow() ?? panic ("dont have this capability")

            log(addedCap.checkCap())

    }


}