//
//  PDFParser.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 18..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class PDFParser {
    enum PDFOperationType:String {
        case text = "Tj"
        case newLineText = "\'"
        case newLineSetSpacing = "\""
        case textAndSpaces = "TJ"
        case endText = "ET"
    }
    
    static var FNMAP:[PDFOperationType:CGPDFOperatorCallback] = [
        // TODO Graphics States Changes

        // Text Operations
        PDFOperationType.text: { parse($0, PDFOperationType.text, $1) },
        PDFOperationType.newLineText: { parse($0, PDFOperationType.newLineText, $1) },
        PDFOperationType.newLineSetSpacing: { parse($0, PDFOperationType.newLineSetSpacing, $1) },
        PDFOperationType.textAndSpaces: { parse($0, PDFOperationType.textAndSpaces, $1) },
        PDFOperationType.endText: { parse($0, PDFOperationType.endText, $1) }
    ]
    
    static func parse(_ scanner:CGPDFScannerRef, _ type:PDFOperationType, _ info:UnsafeRawPointer?) {
        switch type {
        case .text:
            let str = getString(scanner)
            print("beginText \(str)")
            break
        case .newLineText:
            let str = getString(scanner)
            print("newLineText \(str)")
        case .newLineSetSpacing:
            var r:CGPDFReal? = nil
            if CGPDFScannerPopNumber(scanner, &r!) {
                print("newlinesetSpacing :: \(r)")
            }
        case .textAndSpaces:
            var arr:CGPDFArrayRef? = nil
            if CGPDFScannerPopArray(scanner, &arr), let array = arr  {
                for i in 0..<CGPDFArrayGetCount(array) {
                    let pdfObject = getObject(arr:array, index:i)
                    let valueType = CGPDFObjectGetType(pdfObject)
                    if valueType == CGPDFObjectType.string {
                        var str:CGPDFStringRef? = nil
                        if CGPDFObjectGetValue(pdfObject, valueType, &str) {
                            print("clippingText :: \(CGPDFStringCopyTextString(str!))")
                        }
                    } else {
                        // 공백문자 처리
                    }
                }
            }
        default:()
        }
    }
    
    static func getString(_ scanner:CGPDFScannerRef) -> String? {
        var pdfStringRef:CGPDFStringRef? = nil
        if CGPDFScannerPopString(scanner, &pdfStringRef) {
            let ptr = CGPDFStringGetBytePtr(pdfStringRef!)!
            let byteLength = CGPDFStringGetLength(pdfStringRef!)
            // PDF Spec을 보면 기본 스트링 Encoding이 UTF16BE(UTF-16 Big endian notation)이므로 -ㅅ- 그대로 쓰면 CJK쪽 문자열은 다깨짐.. 아래와 같은 변환을
            return String(data: Data(bytes: ptr, count: byteLength), encoding: .utf16)
        }
        return nil
    }
    
    static func getObject(arr:CGPDFArrayRef, index:Int) -> CGPDFObjectRef {
        var o:CGPDFObjectRef? = nil
        CGPDFArrayGetObject(arr, index, &o)
        return o!
    }
    
    static func scanPDF(page:CGPDFPage) {
        if let table = CGPDFOperatorTableCreate() {
            for op in [PDFOperationType.text, PDFOperationType.textAndSpaces, PDFOperationType.endText] {
                CGPDFOperatorTableSetCallback(table, op.rawValue, FNMAP[op]!)
            }
            let stream = CGPDFContentStreamCreateWithPage(page)
            let scanner = CGPDFScannerCreate(stream, table, nil)
            CGPDFScannerScan(scanner)
            CGPDFScannerRelease(scanner)
            CGPDFContentStreamRelease(stream)
            CGPDFOperatorTableRelease(table)
        }
    }
    
    static func parseAnnotations(pageDictionary:CGPDFDictionaryRef) {
        var pageAnnotations:CGPDFArrayRef? = nil
        if CGPDFDictionaryGetArray(pageDictionary, "Annots", &pageAnnotations), let annotations = pageAnnotations {
            let annotationCount = CGPDFArrayGetCount(annotations)
            for j in 0...annotationCount {
                var annotationDictionary:CGPDFDictionaryRef? = nil
                if CGPDFArrayGetDictionary(pageAnnotations!, j, &annotationDictionary) {
                    var nameObj:UnsafePointer<Int8>? = nil
                    if CGPDFDictionaryGetName(annotationDictionary!, "Subtype", &nameObj) {
                        if let annotationSubType = String(validatingUTF8:nameObj!) {
                            print("subtype 있넹.. \(annotationSubType)")
                        }
                    }
                    print("annotation 받음 ... \(annotations), \(annotationDictionary)")
                }
            }
        }
    }
}

