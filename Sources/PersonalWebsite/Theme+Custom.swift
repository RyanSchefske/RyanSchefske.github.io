//
//  Theme+Custom.swift
//  PersonalWebsite
//
//  Created by Ryan Schefske on 1/6/22.
//

import Plot
import Publish

extension Theme where Site == PersonalWebsite {
    static var custom: Self {
        Theme(
            htmlFactory: CustomHTMLFactory(),
            resourcePaths: ["Resources/Themes/styles.css"]
        )
    }

    private struct CustomHTMLFactory: HTMLFactory {
        func makeIndexHTML(for index: Index, context: PublishingContext<PersonalWebsite>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: index, on: context.site),
                .body {
                    SiteHeader(context: context, selectedSelectionID: nil)
                    Wrapper {
                        H1(index.title)
                        Paragraph(context.site.description)
                            .class("description")
                        H2("Latest content")
                        ItemList(items: context.allItems(sortedBy: \.date, order: .descending), site: context.site)
                    }
                }
            )
        }

        func makeSectionHTML(for section: Section<PersonalWebsite>, context: PublishingContext<PersonalWebsite>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: section, on: context.site),
                .body {
                    SiteHeader(context: context, selectedSelectionID: section.id)
                    Wrapper {
                        H1(section.title)
                        ItemList(items: section.items, site: context.site)
                    }
                }
            )
        }

        func makeItemHTML(for item: Item<PersonalWebsite>, context: PublishingContext<PersonalWebsite>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: item, on: context.site),
                .body(
                    .class("item-page"),
                    .components {
                        SiteHeader(context: context, selectedSelectionID: item.sectionID)
                        Wrapper {
                            Article {
                                Div(item.content.body).class("content")
                                Span("Tagged with: ")
                                ItemTagList(item: item, site: context.site)
                            }
                        }
                    }
                )
            )
        }

        func makePageHTML(for page: Page, context: PublishingContext<PersonalWebsite>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body {
                    SiteHeader(context: context, selectedSelectionID: nil)
                    Wrapper(page.body)
                }
            )
        }

        func makeTagListHTML(for page: TagListPage, context: PublishingContext<PersonalWebsite>) throws -> HTML? {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body {
                    SiteHeader(context: context, selectedSelectionID: nil)
                    Wrapper {
                        H1("Browse all tags")
                        List(page.tags.sorted()) { tag in
                            ListItem {
                                Link(tag.string, url: context.site.path(for: tag).absoluteString)
                            }
                            .class("tag")
                        }
                        .class("all-tags")
                    }
                }
            )
        }
        
        func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<PersonalWebsite>) throws -> HTML? {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body {
                    SiteHeader(context: context, selectedSelectionID: nil)
                    Wrapper {
                        H1 {
                            Text("Tagged with ")
                            Span(page.tag.string).class("tag")
                        }
                        
                        Link("Browse all tags",
                             url: context.site.tagListPath.absoluteString
                        )
                            .class("browse-all")
                        
                        ItemList(
                            items: context.items(
                                taggedWith: page.tag,
                                sortedBy: \.date,
                                order: .descending
                            ),
                            site: context.site
                        )
                    }
                }
            )
        }
    }
    
    private struct SiteHeader<Site: Website>: Component {
        var context: PublishingContext<Site>
        var selectedSelectionID: Site.SectionID?
        
        var body: Component {
            Header {
                Wrapper {
                    Link(context.site.name, url: "/")
                        .class("site-name")
                    
                    if Site.SectionID.allCases.count > 1 {
                        navigation
                    }
                }
            }
        }
        
        private var navigation: Component {
            Navigation {
                List(Site.SectionID.allCases) { sectionID in
                    let section = context.sections[sectionID]
                    
                    return Link(section.title, url: section.path.absoluteString)
                        .class(sectionID == selectedSelectionID ? "selected" : "")
                }
            }
        }
    }
    
    private struct Wrapper: ComponentContainer {
        @ComponentBuilder var content: ContentProvider

        var body: Component {
            Div(content: content).class("wrapper")
        }
    }
    
    private struct ItemList<Site: Website>: Component {
        var items: [Item<Site>]
        var site: Site

        var body: Component {
            List(items) { item in
                Article {
                    H1(Link(item.title, url: item.path.absoluteString))
                    ItemTagList(item: item, site: site)
                    Paragraph(item.description)
                }
            }
            .class("item-list")
        }
    }

    private struct ItemTagList<Site: Website>: Component {
        var item: Item<Site>
        var site: Site

        var body: Component {
            List(item.tags) { tag in
                Link(tag.string, url: site.path(for: tag).absoluteString)
            }
            .class("tag-list")
        }
    }
}
