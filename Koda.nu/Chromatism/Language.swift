//
//  JLLanguage.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-17.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public enum Language {
    case c, objectiveC, swift, javascript, other(JLDocumentScope)
    
    
    /**
     Warning: Will probably be changed in the future to take arguments
     
     - returns: A functional JLLanguage object.
     */
    public func documentScope() -> JLDocumentScope {
        
        switch self {
        case .c:
            let blockComments = JLTokenizingScope(incrementingPattern: "/\\*", decrementingPattern: "\\*/", tokenType: .comment, hollow: false)
            let lineComments = JLRegexScope(pattern: "//(.*)", tokenTypes: .comment)
            let preprocessor = JLRegexScope(pattern: "^#.*+$", tokenTypes: .preprocessor)
            let strings = JLRegexScope(pattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenTypes: .string)
            let angularImports = JLRegexScope(pattern: "<.*?>", tokenTypes: .string)
            let numbers = JLRegexScope(pattern: "(?<=\\s)\\d+", tokenTypes: .number)
            let functions = JLRegexScope(pattern: "\\w+\\s*(?>\\(.*\\))", tokenTypes: .otherMethodNames)
            
            let keywords = JLKeywordScope(keywords: "true false YES NO TRUE FALSE bool BOOL nil id void self NULL if else strong weak nonatomic atomic assign copy typedef enum auto break case const char continue do default double extern float for goto int long register return short signed sizeof static struct switch typedef union unsigned volatile while nonatomic atomic nonatomic readonly super", tokenType: .keyword)
            
            return JLDocumentScope()[
                blockComments,
                lineComments,
                preprocessor[
                    strings,
                    angularImports
                ],
                strings,
                numbers,
                functions,
                keywords
            ]
        case .objectiveC:
            let dotNotation = JLRegexScope(pattern: "\\.\\w+", tokenTypes: .otherProperties)
            
            // Note about project class names: When symbolication is supported this pattern should be changed to .OtherClassNames
            let projectClassNames = JLRegexScope(pattern: "\\b[A-Z]{3}[a-zA-Z]*\\b", tokenTypes: .projectClassNames)
            let NSUIClassNames = JLRegexScope(pattern: "\\b(NS|UI)[A-Z][a-zA-Z]+\\b", tokenTypes: .otherClassNames)
            // http://www.learn-cocos2d.com/2011/10/complete-list-objectivec-20-compiler-directives/
            let objcKeywords = JLKeywordScope(keywords: "class defs protocol required optional interface public package protected private property end implementation synthesize dynamic end throw try catch finally synchronized autoreleasepool selector encode compatibility_alias".components(separatedBy: " "), prefix:"@", suffix:"\\b", tokenType: .keyword)
            let squareBrackets: JLTokenizingScope
            let dictionaryLiteral = JLTokenizingScope(incrementingPattern: "\\@\\{", decrementingPattern: "\\}", tokenType: .otherMethodNames, hollow: true)
            _ = JLRegexScope(pattern: "\\b\\w+(:|(?=\\]))", tokenTypes: .otherMethodNames)
            
            let blockComments = JLTokenizingScope(incrementingPattern: "/\\*", decrementingPattern: "\\*/", tokenType: .comment, hollow: false)
            let lineComments = JLRegexScope(pattern: "//(.*)", tokenTypes: .comment)
            let preprocessor = JLRegexScope(pattern: "^#.*+$", tokenTypes: .preprocessor)
            let strings = JLRegexScope(pattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenTypes: .string)
            let angularImports = JLRegexScope(pattern: "<.*?>", tokenTypes: .string)
            let numbers = JLRegexScope(pattern: "(?<=\\s)\\d+", tokenTypes: .number)
            let functions = JLRegexScope(pattern: "\\w+\\s*(?>\\(.*\\))", tokenTypes: .otherMethodNames)
            
            let keywords = JLKeywordScope(keywords: "true false YES NO TRUE FALSE bool BOOL nil id void self NULL if else strong weak nonatomic atomic assign copy typedef enum auto break case const char continue do default double extern float for goto int long register return short signed sizeof static struct switch typedef union unsigned volatile while nonatomic atomic nonatomic readonly super", tokenType: .keyword)
            
            
            let openBracket = JLTokenizingScope.Token(pattern: "\\[", delta: 1)
            let closeBracket = JLTokenizingScope.Token(pattern: "\\]", delta: -1)
            let arrayOpen = JLTokenizingScope.Token(pattern: "\\@\\[", delta: 1)
            
            let method = JLNestedScope(incrementingToken: openBracket, decrementingToken: closeBracket, tokenType: .none, hollow: false)
            let arrayLiteral = JLNestedScope(incrementingToken: arrayOpen, decrementingToken: closeBracket, tokenType: .otherMethodNames, hollow: true)
            squareBrackets = JLTokenizingScope(tokens: [arrayOpen, openBracket, closeBracket])

            
            return JLDocumentScope()[
                blockComments,
                dictionaryLiteral,
                lineComments,
                preprocessor[strings, angularImports],
                squareBrackets[
                    arrayLiteral,
                    method[
                        strings,
                        numbers,
                        functions,
                        keywords,
                        dotNotation,
                        objcKeywords,
                        NSUIClassNames,
                        projectClassNames
                    ]
                ],
                strings,
                numbers,
                functions,
                keywords,
                dotNotation,
                objcKeywords,
                NSUIClassNames,
                projectClassNames]
            
        case .swift:
            let blockComments = JLTokenizingScope(incrementingPattern: "/\\*", decrementingPattern: "\\*/", tokenType: .comment, hollow: false)
            let lineComments = JLRegexScope(pattern: "//(.*)", tokenTypes: .comment)
            let keywords = JLKeywordScope(keywords: "class protocol init required public internal import private nil super var let func override deinit return true false", tokenType: .keyword)
            let atKeywords = JLKeywordScope(keywords: ["optional", "UIApplicationMain"], prefix: "@", suffix: "\\b", tokenType: .keyword)
            let projectClassNames = JLRegexScope(pattern: "\\b[A-Z]{3}[a-zA-Z]+\\b", tokenTypes: .projectClassNames)
            let NSUIClassNames = JLRegexScope(pattern: "\\b(NS|UI)[A-Z][a-zA-Z]+\\b", tokenTypes: .otherClassNames)
            let swiftTypes = JLKeywordScope(keywords: "", tokenType: .otherClassNames)
            let dotNotation = JLRegexScope(pattern: "\\.\\w+", tokenTypes: .otherProperties)
            let functions = JLRegexScope(pattern: "\\b(println)(?=\\()", tokenTypes: .otherMethodNames)
            let strings = JLRegexScope(pattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenTypes: .string)
            let numbers = JLRegexScope(pattern: "(?<=\\s)\\d+", tokenTypes: .number)
            let interpolation = JLRegexScope(pattern: "(?<=\\\\\\().*?(?=\\))", tokenTypes: .text)
            return JLDocumentScope()[
                blockComments,
                lineComments,
                keywords,
                atKeywords,
                strings[
                    interpolation
                ],
                numbers,
                swiftTypes,
                dotNotation,
                NSUIClassNames,
                functions,
                projectClassNames
            ]
            
            
        case .javascript:
            let blockComments = JLTokenizingScope(incrementingPattern: "/\\*", decrementingPattern: "\\*/", tokenType: .comment, hollow: false)
            let lineComments = JLRegexScope(pattern: "//(.*)", tokenTypes: .comment)
            let keywords = JLKeywordScope(keywords: "do if in for let new try var case else enum eval null this true void with await break catch class const false super throw while yield delete export import public return static switch typeof default extends finally package private continue debugger function arguments interface protected implements instanceof Infinity NaN undefined", tokenType: .keyword)
            let atKeywords = JLKeywordScope(keywords: ["optional", "UIApplicationMain"], prefix: "@", suffix: "\\b", tokenType: .keyword)
            let projectClassNames = JLRegexScope(pattern: "\\b[A-Z]{3}[a-zA-Z]+\\b", tokenTypes: .projectClassNames)
            let NSUIClassNames = JLRegexScope(pattern: "\\b(NS|UI)[A-Z][a-zA-Z]+\\b", tokenTypes: .otherClassNames)
            let swiftTypes = JLKeywordScope(keywords: "", tokenType: .otherClassNames)
            let dotNotation = JLRegexScope(pattern: "\\.[^\\d]+", tokenTypes: .otherProperties)
            let functions = JLRegexScope(pattern: "\\b(println)(?=\\()", tokenTypes: .otherMethodNames)
            let strings = JLRegexScope(pattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenTypes: .string)
            let numbers = JLRegexScope(pattern: "[^a-zA-Z ]*(\\d+)[^a-zA-Z ]*", tokenTypes: .number)
            let interpolation = JLRegexScope(pattern: "(?<=\\\\\\().*?(?=\\))", tokenTypes: .text)
            return JLDocumentScope()[
                blockComments,
                lineComments,
                keywords,
                atKeywords,
                strings[
                    interpolation
                ],
                numbers,
                swiftTypes,
                dotNotation,
                NSUIClassNames,
                functions,
                projectClassNames
            ]

            
        case .other(let scope):
            return scope
        }
    }
}


