@ECHO OFF

echo "Building PDF-friendly HTML site..."

jekyll serve --detach --config _config.yml,pdfconfigs/config_pdf.yml

echo "done"

echo "Building the PDF ..."

prince --javascript --input-list=_site/pdfconfigs/prince-list.txt -o pdf/bonsai-anylogic-workflow.pdf;

echo "done"