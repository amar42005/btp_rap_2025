@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Vendor Invoice Item - Transactional'
//@ObjectModel.transactionalProcessingEnabled: true
//@ObjectModel.writeActivePersistence: 'ZSTG_VEND_INV_I' // Name of the item staging table
define view entity ZI_VendorInvoiceItem_TP

  as select from zstg_vend_inv_i as Item
  association to parent ZI_VendorInvoiceHead_TP as _Header on $projection.ParentUuid = _Header.InvoiceUuid
{
  key Item.item_uuid          as ItemUuid,
  key Item.parent_uuid        as ParentUuid, // Foreign key to header
      Item.item_number        as ItemNumber,
      Item.gl_account_number  as GlAccountNumber,
      Item.amount_in_doc_curr as AmountInDocumentCurrency,
      Item.tax_code           as TaxCode,
      Item.cost_center        as CostCenter,
      Item.profit_center      as ProfitCenter,
      Item.order_number       as OrderNumber,
      Item.wbs_element        as WbsElement,
      Item.assignment_number  as AssignmentNumber,
      Item.item_text          as ItemText,
      /* Associations */
      _Header
}
