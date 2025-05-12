// Abstract Entity for Action Parameter/Result (Optional, but good practice for complex results)
@EndUserText.label: 'Invoice Posting Result Structure'
define abstract entity ZP_InvoicePostResult
{
  Success           : abap_boolean;
  SapDocumentNumber : belnr_d;
  SapFiscalYear     : gjahr;
  Message           : abap.string(0);
}
