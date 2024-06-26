<table width="100%" class="datatable table table-hover table-bordered tc-table ">
    <thead>
    <tr>
        <th>Nama Layanan</th>
        <th>Status</th>
        <th>Berakhir Dalam */hari</th>
        <th>Jumlah</th>

        <th>Opsi</th>
    </tr>
    </thead>
    <tbody>

    {foreach from=$hostings key=k item=v name=ind}

        {assign var="cycle" value=$v.billingcycle}
        <tr>
            <td>
                {$v.product} - {$v.domain}


            </td>

            <td>
                <label class="label label-{if $v.status|strtolower eq 'active'}success{else}danger{/if}">
                    {if $v.status eq 'Active'}
                        Aktif
                    {elseif $v.status eq 'Suspended'}
                        Suspended
                    {/if}
                </label>
            </td>
            {if $v.billingcycle eq 'Free Account'}
                <td colspan="4" style="text-align: center">Layanan Ini Tidak Dapat Di Perpanjang</td>
            {else}
                <td>{$v.daysleft}</td>
                {if $v.cancel gt 0}
                    <td colspan="3" style="text-align: center">Permintaan Pembatalan Layanan Sedang Di Tinjau</td>
                {else}
                    <td>{$v.amount}$</td>

                    <td>
                        {if $v.invoicecount gt 0}
                            <a class="btn blue " href="{if $v.invoicecount eq 1}creditcard.php?invoiceid={$v.invoiceid}{else}clientarea.php?action=invoices{/if}">
                                <i class="fa fa-credit-card" aria-hidden="true"></i>
                                Bayar Sekarang</a>
                        {else}
                            <a href="javascript:void(0)" class="btn blue  renewthisproduct" data-producttype="hosting" data-productname="{$v.product}" data-hostingid="{$v.id}" data-addonsid="{$v.addonsid}" data-daysmore="{$v.dayswilladd}" data-totalamount="{$v.totalamount}" data-domain="{$v.domain}" data-addonsprice="{$v.addonstotal}" data-productprice="{$v.amount}">
                                <i class="fa fa-repeat" aria-hidden="true"></i> {$cycles.$cycle}Perpanjang</a>
                        {/if}

                        {if $v.invoicecount gt 0}
                            <a href="javascript:void(0)" class="softwarning"  data-text="Silakan Lakukan Pembayaran Sebesar Rp.{$v.invoicetotal}"><i class="fa fa-comment " aria-hidden="true"></i></a>
                        {/if}
                    </td>
                {/if}
            {/if}
        </tr>
    {/foreach}

    {foreach from=$domains key=k item=v name=ind}
        <tr>
            <td>Domain : {$v.domain}</td>
            <td>
                <label class="label label-{if $v.status|strtolower eq 'active'}success{else}danger{/if}">  {if $v.status eq 'Active'} Aktif {elseif $v.status eq 'Expired'} Expired {/if} </label>
            </td>
            <td>{$v.daysleft}</td>
            <td>{$v.recurringamount}$</td>


            <td>


                {if $v.invoicecount gt 0}
                    <a class="btn blue " href="{if $v.invoicecount eq 1}creditcard.php?invoiceid={$v.invoiceid}{else}clientarea.php?action=invoices{/if}">
                        <i class="fa fa-credit-card" aria-hidden="true"></i>
                        Bayar Sekarang</a>
                {else}
                    <div class="btn-group">
                        <a href="javascript:void(0)" class="btn blue  dropdown-toggle" data-toggle="dropdown">
                            <i class="fa fa-repeat" aria-hidden="true"></i>
                            Perpanjang </a>
                        {if $v.pricings gt 1}
                            <ul class="dropdown-menu" role="menu">
                                {foreach from=$v.pricings key=kpr item=vpr name=indpr}
                                    <li>
                                        <a href="javascript:void(0)" class="renewthisdomain" data-producttype="domain" data-domain="{$v.domain}" data-domainid="{$v.id}" data-year="{$kpr}" data-productprice=" {$vpr} " domain-redemption="{if $v.daysleft gt -30}0{else}1{/if}" data-addonsid="0">{$kpr} Perpanjang Setahun ({$vpr}$)</a>
                                    </li>
                                {/foreach}
                            </ul>
                        {/if}
                    </div>
                {/if}


                {if $v.invoicecount gt 0}
                    <a href="javascript:void(0)" class="softwarning"  data-text="Silakan Lakukan Pembayaran Sebesar Rp.{$v.invoicetotal}"><i class="fa fa-comment " aria-hidden="true"></i></a>
                {/if}


            </td>
        </tr>
    {/foreach}

    </tbody>

</table>


<style>
    .page-header {
        display: none;
    }

    .tooltip-inner {
        white-space: pre-wrap;
    }
</style>


{include file="./assets.tpl"}
