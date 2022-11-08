#include <openssl/x509_vfy.h>
#include <stdio.h>
#include "certbundle.h"
typedef x509_store_st X509_STORE;


int main()
{
    SSL_CTX* ctx;

    BIO *cbio = BIO_new_mem_buf(ca_bundle.data(), ca_bundle.size());
    X509_STORE  *cts = SSL_CTX_get_cert_store(ctx.native_handle());
    if(!cts || !cbio)
       return false;
    X509_INFO *itmp;
    int i, count = 0, type = X509_FILETYPE_PEM;
    STACK_OF(X509_INFO) *inf = PEM_X509_INFO_read_bio(cbio, NULL, NULL, NULL);

    if (!inf)
    {
        BIO_free(cbio);//cleanup
        return false;
    }
    //itterate over all entries from the pem file, add them to the x509_store one by one
    for (i = 0; i < sk_X509_INFO_num(inf); i++) {
        itmp = sk_X509_INFO_value(inf, i);
        if (itmp->x509) {
              X509_STORE_add_cert(cts, itmp->x509);
              count++;
        }
        if (itmp->crl) {
              X509_STORE_add_crl(cts, itmp->crl);
              count++;
        }
    }
    sk_X509_INFO_pop_free(inf, X509_INFO_free); //cleanup
    BIO_free(cbio);//cleanup
    

    return 0;
}

/*
*/
