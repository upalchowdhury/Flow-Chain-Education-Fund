import FungibleToken from 0x01
import FlowToken from 0x02
import EducationFund from 0x03


transaction(Limit:UFix64) {


    prepare(acct: AuthAccount) {
       let capRef = acct.getCapability
       <&EducationFund.Parent{EducationFund.AddUpadateCapability}>
       (EducationFund.ParentUpdatePrivatePath).borrow()
            ?? panic("Could not borrow capability")
           // log("capability cant be borrowed")

        capRef.UpdateFundConf(Limit: Limit)

     
    }
}