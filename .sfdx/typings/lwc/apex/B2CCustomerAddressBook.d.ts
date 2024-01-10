declare module "@salesforce/apex/B2CCustomerAddressBook.getCustomerAddressLabels" {
  export default function getCustomerAddressLabels(): Promise<any>;
}
declare module "@salesforce/apex/B2CCustomerAddressBook.getCustomerAddressFormFields" {
  export default function getCustomerAddressFormFields(): Promise<any>;
}
declare module "@salesforce/apex/B2CCustomerAddressBook.getCustomerAddresses" {
  export default function getCustomerAddresses(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/B2CCustomerAddressBook.getCustomerAddressById" {
  export default function getCustomerAddressById(param: {customerId: any, addressId: any}): Promise<any>;
}
declare module "@salesforce/apex/B2CCustomerAddressBook.patchCustomerAddress" {
  export default function patchCustomerAddress(param: {customerId: any, addressId: any, address: any}): Promise<any>;
}
