<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

{literal}
    <script type="text/javascript">

      $(document).ready(function() {

        $(document).on('click', '.renewthisproduct , .renewthisdomain', function() {
          const {
                  domain,
                  hostingid,
                  domainid,
                  addonsid,
                  daysmore,
                  totalamount,
                  productprice,
                  addonsprice,
                  productname,
                  producttype,
                  year: domainyear,
                } = $(this).data(); // jQuery .data() penggunaan destrukturisasi dengan

          let addonscount;
          if (typeof addonsid === 'string') {
            addonscount = addonsid.split(',').length;
          }
          else {
            // addonsid string değilse, uygun bir varsayılan değer atayın
            addonscount = 0; // veya beklenen bir değer
          }

          let warningtext = '';
          if (producttype === 'hosting') {
            warningtext = `${domain} Ringkasan biaya untuk layanan ini adalah sebagai berikut.<br>
                <table width="100%" class="datatable table">
                  <tbody>
                    <tr> <td>Nama Layanan</td> <td>${productname}</td> </tr>
                    <tr> <td>Harga Layanan</td> <td>${productprice}$</td> </tr>
                    ${addonscount > 1 ? `<tr> <td>Jumlah Plugin</td> <td>${addonscount}</td> </tr>
                      <tr> <td>Harga Plugin</td> <td>${addonsprice}$</td> </tr>` : ''}
                    <tr> <td>Hari yang Diperpanjang</td> <td>${daysmore}</td> </tr>
                    <tr> <td>Jumlah Harga</td> <td>${totalamount}$</td> </tr>
                  </tbody>
                </table>
                <br><i>Klik tombol Perbarui untuk melanjutkan layanan Anda. Ketika Anda mengklik tombol tersebut, Anda akan diarahkan ke layar pembayaran.
                `;
          }
          else if (producttype === 'domain') {
            warningtext = `${domain} Ringkasan biaya untuk nama domain adalah sebagai berikut.<br>
                <table width="100%" class="datatable table">
                  <tbody>
                    <tr> <td>Nama Domain</td> <td>${domain}</td> </tr>
                    <tr> <td>Harga Domain</td> <td>${productprice}$</td> </tr>
                    <tr> <td>Perpanjang dalam Setahun</td> <td>${domainyear}</td> </tr>
                  </tbody>
                </table>
                <br><i>Klik tombol Renew untuk memperpanjang nama domain Anda. Ketika Anda mengklik tombol tersebut, Anda akan diarahkan ke layar pembayaran.
                `;
          }

          const postparams = producttype === 'hosting'
              ? {type: 'hosting', hostingid, addonsid}
              : {type: 'domain', domainid, years: domainyear};

          var gotourl = '';
          Swal.fire({
            title              : 'Info!',
            html               : warningtext,
            icon               : 'info', // 'type' yerine 'icon' kullanılıyor
            showCancelButton   : true,
            confirmButtonColor : '#DD6B55',
            confirmButtonText  : 'Perpanjang',
            cancelButtonText   : 'Batal',
            showLoaderOnConfirm: true,
            allowOutsideClick  : false,
            preConfirm         : () => {
              return new Promise((resolve, reject) => {
                $.post('index.php?m=hosting_renew&method=renewproduct', postparams).done(data => {

                  if (data.result === 'success') { // '=' yerine '===' kullanılmalı
                    gotourl = 'creditcard.php?invoiceid=' + data.invoiceid;
                    resolve();
                  }else if (data.result === 'redirect') { // '=' yerine '===' kullanılmalı


                    $.post('cart.php?a=add&renewals=true', data.querystring).done(data => {
                      gotourl = 'cart.php?a=view';
                      resolve();
                    })


                  }
                  else {
                    Swal.showValidationMessage( // 'reject' yerine 'Swal.showValidationMessage' Sedang Berjalan
                        'Sebuah kesalahan telah terjadi. Silakan buka tiket dukungan',
                    );
                  }
                }).fail(() => {
                  Swal.showValidationMessage(
                      'Terjadi kesalahan saat memproses permintaan.',
                  );
                });
              });
            },
          }).then((result) => {
            if (result.value) {
              Swal.fire({
                icon             : 'success',
                title            : 'Anda sedang diarahkan.',
                showConfirmButton: false,
                timer            : 1500, // Belirli bir süre sonra otomatik kapanması için timer eklendi
              });

              window.location.href = gotourl;
            }
          }).catch((error) => {
            // Hata yönetimi için catch bloğu eklendi
            console.error('Internal Server Error:', error);
          });

        });

        $(document).on("click",'.softwarning', function(){

          let text = $(this).data('text');
            Swal.fire({
                title: 'Info',
                text: text,
                icon: 'warning',
                confirmButtonText: 'Oke'
            });

        });

      });


    </script>
{/literal}