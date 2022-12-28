class OrderPdfTemplateData < ActiveRecord::Migration[6.1]
  def change
    add_column :pdf_templates, :method_name, :string, if_not_exists: true
    pdf_temp = PdfTemplate.create(table_name: 'order', method_name: 'index', title: 'OrderData')
    data = [{
                title: 'account_statement',
                pdf_template_id: pdf_temp.id,
                content: '<div style="margin-top: 50px;"><h1 style="text-align: center;">Account Statement</h1>
                          <div>
                            <h2 style="text-align: left;" class="lite-gray">Client`s details</h2>
                            <table class="pdf_font1">
                              <tr>
                                <td style="font-weight: bold;">Registration No:</td>
                                <td>[[sys_user_code]]</td>
                                <td rowspan="5">
                                  <div style="float: right;">
                                    <img src="[[sys_user_img]]" height="100px" width="100px" />
                                  </div>
                                </td>
                              </tr>
                              <tr>
                                <td style="font-weight: bold;">CNIC No:</td>
                                <td>[[sys_user_cninc]]</td>
                                <td></td>
                                <td></td>
                              </tr>
                              <tr>
                                <td style="font-weight: bold;">Member Name:</td>
                                <td>[[sys_user_name]]</td>
                                <td></td>
                                <td></td>
                              </tr>
                              <tr>
                                <td style="font-weight: bold;">Address:</td>
                                <td><p style="padding: 0px 0px 0px 0px; width: 300px; line-height: 10pt;">[[sys_user_address]]</p></td>
                                <td></td>
                                <td></td>
                              </tr>
                              <tr>
                                <td style="width:33vw; font-weight: bold;">Contacts:</td>
                                <td style="width:33vw;">[[sys_user_contact]]</td>
                                <td></td>
                                <td></td>
                              </tr>
                            </table>
                          </div></div>'
            },
            {
              title: 'property_details',
              pdf_template_id: pdf_temp.id,
              content: '<table class="pdf_font">
                        <tr>
                          <td style="width:120px; font-weight: bold;">Block Name:</td>
                          <td >[[block_name]]</td>
                          <td style="width:120px; font-weight: bold;">Property Size: </td>
                          <td>[[property_size_m]]-M [[property_size_sqr]]-Sqr</td>
                        </tr>
                        <tr>
                          <td style="width:120px; font-weight: bold;">Property No.</td>
                          <td >[[property_no]]</td>
                          <td style="width:120px; font-weight: bold;">Type:</td>
                          <td >[[type]]</td>
                        </tr>
                      </table>'
            },
            {
              title: 'payment_details',
              pdf_template_id: pdf_temp.id,
              content: '<h2 style="text-align: left; margin: 0;" class="lite-gray">Payment details</h2>
            <div>
              <table class="pdf_font">
                <tr>
                  <td style="width:120px; font-weight: bold;">Net Price:</td>
                  <td >[[net_price]]</td>
                  <td style="width:120px; font-weight: bold;">Grand Due Amt: </td>
                  <td>[[due_amt]]</td>
                  <td style="width:120px; font-weight: bold;">Net Price Received:</td>
                  <td>[[price_recieved]]</td>
                </tr>
                <tr>
                  <td style="width:120px; font-weight: bold;">Grand Received %: </td>
                  <td>[[grand_recieved]]</td>
                  <td style="width:150px; font-weight: bold;">Net Price O.S Amt:</td>
                  <td >[[sys_user_name]]</td>
                  <td style="width:150px; font-weight: bold;">Cash Discount: </td>
                  <td>[[cash_discount]]</td>
                </tr>
              </table>
            </div>'
            },
            {
              title: 'property_plans',
              pdf_template_id: pdf_temp.id,
              content: '<tr class="lite-gray">
                      <th>Inst#</th>
                      <th>Due Date</th>
                      <th>Due</th>
                      <th>Inst#</th>
                      <th>Due Date</th>
                      <th>Due</th>
                    </tr>
                    <tr>
                      <td class="lite-gray"></td>
                      <td style="text-align:left">Down Payment</td>
                      <td style="text-align:right">
                        <b>[[property_advance]]</b>
                        [[property_status]]
                      </td>
                      <td class="lite-gray"></td>
                      <td></td>
                      <td></td>
                    </tr>'
            },
            {
              title: 'delivery_details',
              pdf_template_id: pdf_temp.id,
              content: '<tr class="lite-gray">
                    <td></td>
                    <th>Delivery Detail</th>
                    <th>Received</th>
                    <th>Date/Time</th>
                    <th>Comment</th>
                  </tr>
                  <tr>
                    <td></td>
                    <td>Booking</td>
                    <td>[[order_amount]]</td>
                    <td>[[order_date]]</td>
                    <td>[[order_comment]]</td>
                  </tr>'
            },
            {
              title: 'transfer_details',
              pdf_template_id: pdf_temp.id,
              content: "<tr>
                      <td><h3>[[comment]]</h3></td>
                      <td><h3>[[body]]</h3></td>
                      <td>[[message]]</td>
                      <td>[[date]]</td>
                    </tr>"
            },
            {
              title: 'web_links',
              pdf_template_id: pdf_temp.id,
              content: '<tr>
                      <td>
                        <img width="150px" height="115px" class="figure" style=""src=[[qr_first]] />
                      </td>
                      <td>
                        <h4 style="text-align:left">For verification of your Unit booking:</h4>
                        <p style="text-align:left"> 1) Open Camrea/QRScaner app on your phone</p>
                        <p style="text-align:left"> 2) Point your phone to this QRCODE to capture the code</p>
                        <p style="text-align:left"> 3) After capturing you will redirect to Company Sites</p>
                      </td>
                      <td>
                            <img width="150px" height="115px" class="figure" style=""src=[[qr_last]] />
                      </td>
                    </tr>'
            },
            {
              title: 'booking_qr',
              pdf_template_id: pdf_temp.id,
              content: '<img width="150px" height="115px" class="figure" style="postition: fixed; top: 20px;"src="[[qr_src]]" />'
            },
            {
              title: 'account_signature',
              pdf_template_id: pdf_temp.id,
              content: '<div>
                <table data-toggle="table" data-search="true">
                  <tbody>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4">Account Department Signature</th>
                      <th style="text-align:center">Customer Signature</th>
                    </tr>
                  </tbody>
                </table>
            </div>'
            },
            {
              title: 'booking_qr_else',
              pdf_template_id: pdf_temp.id,
              content: '<img width="150px" height="115px" class="figure" style=""src=[[qr_src]] />'
            },
            {
              title: 'company_signature',
              pdf_template_id: pdf_temp.id,
              content: '<div>
                <table data-toggle="table" data-search="true">
                  <tbody>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4"></th>
                      <th style="text-align:center" colspan="4"></th>
                    </tr>
                    <tr>
                      <th style="text-align:left" colspan="4">Company Signature</th>
                      <th style="text-align:center">Customer Signature</th>
                    </tr>
                  </tbody>
                </table>
            </div>'
            },
            {
              title: 'pdf_footer',
              pdf_template_id: pdf_temp.id,
              content: '<div class="footer">
                  <p style="border-bottom: double 4px;  margin: 0;"></p>
                  <p style="margin: 0;"><span></span></p>
                  <p style="margin: 0;"><span></span></p>
                  <p style="border-bottom: double 4px;  margin: 0;"></p>
                </div>'
            },
            {
              title: 'pdf_header',
              pdf_template_id: pdf_temp.id,
              content: '<div class="header" style="height: 180px;">
            <div class="logo_left_text_center"><img src= "[[image]]" height="170px" width="170px"/></div>
            <div class="logo_left_text_center_text" style="padding-top: 80px;"><h1>Test</h1></div>
            </div>'
            }]
    data.each do |d|
      PdfTemplateElement.create(title: d[:title], pdf_template_id: d[:pdf_template_id], content: d[:content])
    end
  end
end
