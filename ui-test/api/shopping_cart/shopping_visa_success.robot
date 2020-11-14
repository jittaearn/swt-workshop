*** Settings ***
Library    RequestsLibrary
Suite Setup    Create Session    alias=shopping    url=https://www.dminer.in.th

*** Variables ***
#ค่า header เป็น key value ต้องใช้ &
&{headers}    Content-Type=application/json    Accept=application/json

*** Test Cases ***
user ซื้อของเล่นให้ลูกสาวเลือกวิธีการจัดส่งเป็น kerry และชำระเงินด้วยบัตรเครดิต visa และชำระเงินสำเร็จ
    Search 
    Product Detail
    Submit Order
    Comfirm Payment


*** Keywords ***
Search
    ${resp}=    Get Request    alias=shopping    uri=/api/v1/product    headers=&{headers} 
    Request Should Be Successful    ${resp}
    Should Be Equal As Integers    ${resp.json()['total']}    2
    Should Be Equal    ${resp.json()['products'][1]['product_name']}    43 Piece dinner Set
    Should Be Equal As Numbers    ${resp.json()['products'][1]['product_price']}    12.95
    ${productId}=    Set Variable    ${resp.json()['products'][1]['id']}
    Set Test Variable    ${productId}

Product Detail
    ${resp}=    Get Request    alias=shopping    uri=/api/v1/product/${productId}    headers=&{headers}
    Request Should Be Successful    ${resp}
    Should Be Equal As Integers    ${resp.json()['id']}    2
    Should Be Equal    ${resp.json()['product_name']}    43 Piece dinner Set
    Should Be Equal As Numbers    ${resp.json()['product_price']}    12.95
    Should Be Equal    ${resp.json()['product_image']}    /43_Piece_dinner_Set.png
    Should Be Equal As Integers    ${resp.json()['quantity']}    10
    Should Be Equal    ${resp.json()['product_brand']}    CoolKidz

Submit Order
    ${data}=    To json    { "cart" : [ { "product_id": 2, "quantity": 1}],"shipping_method" : "Kerry","shipping_address" : "405/37 ถ.มหิดล","shipping_sub_district" : "ต.ท่าศาลา","shipping_district" : "อ.เมือง","shipping_province" : "จ.เชียงใหม่","shipping_zip_code" : "50000","recipient_name" : "ณัฐญา ชุติบุตร","recipient_phone_number" : "0970809292"}
    ${resp}=    Post Request    alias=shopping    uri=/api/v1/order     headers=${headers}    json=${data}
    Request Should Be Successful    ${resp}
    Should Be Equal As Integers    ${resp.json()['order_id']}    8004359122
    Should Be Equal As Numbers    ${resp.json()['total_price']}    14.95 
    ${orderId}=    Set Variable    ${resp.json()['order_id']}
    Should Be Equal As Integers     ${orderId}    8004359122
    Set Test Variable    ${orderId}
    

Comfirm Payment
    ${data}    To Json    {"order_id" : ${orderId},"payment_type" : "credit","type" : "visa","card_number" : "4719700591590995","cvv" : "752","expired_month" : 7,"expired_year" : 20,"card_name" : "Karnwat Wongudom","total_price" : 14.95}
    ${resp}=    Post Request    alias=shopping    uri=/api/v1/confirmPayment    headers=${headers}    json=${data}
    Request Should Be Successful    ${resp}
    Should Be Equal    ${resp.json()['notify_message']}    วันเวลาที่ชำระเงิน 1/3/2020 13:30:00 หมายเลขคำสั่งซื้อ 8004359122 คุณสามารถติดตามสินค้าผ่านช่องทาง Kerry หมายเลข 1785261900
