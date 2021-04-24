jira.md
===

# Change quicksearch styling

Add to Announcement Banner
```
<!--Temporary Style for Search Box-->

<style>
    #quickSearchInput {
        border-radius: 5em;
        background: rgba(255,255,255,1);
        color: rgba(0, 0, 0, 0.7);
    }

    #quickSearchInput::-webkit-input-placeholder {
        color: rgba(0, 0, 0, 0.7);
    }

    #quickSearchInput:-moz-placeholder {
        /#quickSearchInput FF 4-18 #quickSearchInput/
        color: rgba(0, 0, 0, 0.7);
    }

    #quickSearchInput::-moz-placeholder {
        color: rgba(0, 0, 0, 0.7);
    }

    #quickSearchInput:-ms-input-placeholder {
        color: rgba(0, 0, 0, 0.7);
    }

    .aui-header .aui-quicksearch::after {
        color: rgba(0, 0, 0, 0.7);
    }

    .aui-nav .active .aui-icon {
        color: rgba(1, 143, 65, 1);
    }

    .aui-nav li:hover .aui-icon {
        color: rgba(255, 255, 255, 1);
    }

    .aui-nav .active .aui-icon {
        color: rgba(255, 255, 255, 1);
    }
</style>

<!--Temporary Style for Search Box End-->
```
